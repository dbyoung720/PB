/*
 * (C) 2016-2020 see Authors.txt
 *
 * This file is part of MPC-BE.
 *
 * MPC-BE is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * MPC-BE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "stdafx.h"
#include "HTTPAsync.h"
#include "Log.h"
#include "Version.h"

void CALLBACK CHTTPAsync::Callback(_In_ HINTERNET hInternet,
								   __in_opt DWORD_PTR dwContext,
								   __in DWORD dwInternetStatus,
								   __in_opt LPVOID lpvStatusInformation,
								   __in DWORD dwStatusInformationLength)
{
	auto* pContext = (CHTTPAsync*)dwContext;
	auto* pRes     = (INTERNET_ASYNC_RESULT*)lpvStatusInformation;
	switch (pContext->m_context) {
		case Context::CONTEXT_CONNECT:
			if (dwInternetStatus == INTERNET_STATUS_HANDLE_CREATED) {
				pContext->m_hConnect = (HINTERNET)pRes->dwResult;
				SetEvent(pContext->m_hConnectedEvent);
			}
			break;
		case Context::CONTEXT_REQUEST:
			{
				switch (dwInternetStatus) {
					case INTERNET_STATUS_HANDLE_CREATED:
						{
							pContext->m_hRequest = (HINTERNET)pRes->dwResult;
							pContext->m_bRequestComplete = TRUE;
							SetEvent(pContext->m_hRequestOpenedEvent);
						}
						break;
					case INTERNET_STATUS_REQUEST_SENT:
						{
							DWORD* lpBytesSent = (DWORD*)lpvStatusInformation;
							UNREFERENCED_PARAMETER(lpBytesSent);
						}
						break;
					case INTERNET_STATUS_REQUEST_COMPLETE:
						{
							pContext->m_bRequestComplete = TRUE;
							SetEvent(pContext->m_hRequestCompleteEvent);
						}
						break;
					case INTERNET_STATUS_REDIRECT:
						{
							CString strNewAddr = (LPCWSTR)lpvStatusInformation;
							UNREFERENCED_PARAMETER(strNewAddr);
						}
						break;
					case INTERNET_STATUS_RESPONSE_RECEIVED:
						{
							DWORD* dwBytesReceived = (DWORD*)lpvStatusInformation;
							UNREFERENCED_PARAMETER(dwBytesReceived);
						}
						break;
					}
			}
	}
}

CString CHTTPAsync::QueryInfoStr(DWORD dwInfoLevel) const
{
	CheckPointer(m_hRequest, L"");

	CString queryInfo;
	DWORD   dwLen = 0;
	if (!HttpQueryInfoW(m_hRequest, dwInfoLevel, nullptr, &dwLen, 0) && dwLen) {
		const DWORD dwError = GetLastError();
		if (dwError == ERROR_INSUFFICIENT_BUFFER
				&& HttpQueryInfoW(m_hRequest, dwInfoLevel, (LPVOID)queryInfo.GetBuffer(dwLen), &dwLen, 0)) {
			queryInfo.ReleaseBuffer(dwLen);
		}
	}

	return queryInfo;
}

DWORD CHTTPAsync::QueryInfoDword(DWORD dwInfoLevel) const
{
	CheckPointer(m_hRequest, 0);

	DWORD dwStatusCode = 0;
	DWORD dwStatusLen  = sizeof(dwStatusCode);
	HttpQueryInfoW(m_hRequest, HTTP_QUERY_FLAG_NUMBER | dwInfoLevel, &dwStatusCode, &dwStatusLen, 0);

	return dwStatusCode;
}

CHTTPAsync::CHTTPAsync()
{
	m_hConnectedEvent       = CreateEventW(nullptr, FALSE, FALSE, nullptr);
	m_hRequestOpenedEvent   = CreateEventW(nullptr, FALSE, FALSE, nullptr);
	m_hRequestCompleteEvent = CreateEventW(nullptr, FALSE, FALSE, nullptr);
}

CHTTPAsync::~CHTTPAsync()
{
	Close();

	if (m_hConnectedEvent) {
		CloseHandle(m_hConnectedEvent);
	}
	if (m_hRequestOpenedEvent) {
		CloseHandle(m_hRequestOpenedEvent);
	}
	if (m_hRequestCompleteEvent) {
		CloseHandle(m_hRequestCompleteEvent);
	}
}

static CString FormatErrorMessage(DWORD dwError)
{
	CString errMsg;

	LPVOID lpMsgBuf = nullptr;
	if (FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS |
					   FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_FROM_HMODULE,
					   GetModuleHandleW(L"wininet"), dwError,
					   MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
					   (LPWSTR)&lpMsgBuf, 0, nullptr) > 0) {
		errMsg = (LPWSTR)lpMsgBuf;
		errMsg.TrimRight(L"\r\n");
		LocalFree(lpMsgBuf);
	}

	if (dwError == ERROR_INTERNET_EXTENDED_ERROR) {
		CString internetInfo;
		DWORD   dwLen = 0;
		if (!InternetGetLastResponseInfoW(&dwError, nullptr, &dwLen) && dwLen) {
			const DWORD dwLastError = GetLastError();
			if (dwLastError == ERROR_INSUFFICIENT_BUFFER
					&& InternetGetLastResponseInfoW(&dwError, internetInfo.GetBuffer(dwLen), &dwLen)) {
				internetInfo.ReleaseBuffer(dwLen);
				if (!internetInfo.IsEmpty()) {
					errMsg += L", " + internetInfo;
					errMsg.TrimRight(L"\r\n");
				}
			}
		}
	}

	return errMsg;
}

#define SAFE_INTERNET_CLOSE_HANDLE(p) { if (p) { VERIFY(InternetCloseHandle(p)); (p) = nullptr; } }
#define CheckLastError(lpszFunction, ret) \
{ \
	const DWORD dwError = GetLastError(); \
	if (dwError != ERROR_IO_PENDING) { \
		DLog(L"CHTTPAsync() error : Function '%s' failed with error %d - '%s', line %i", lpszFunction, dwError, FormatErrorMessage(dwError).GetString(), __LINE__); \
		return (ret); \
	} \
} \

void CHTTPAsync::Close()
{
	ResetEvent(m_hConnectedEvent);
	ResetEvent(m_hRequestOpenedEvent);
	ResetEvent(m_hRequestCompleteEvent);

	if (m_hInstance) {
		InternetSetStatusCallbackW(m_hInstance, nullptr);
	}

	SAFE_INTERNET_CLOSE_HANDLE(m_hRequest);
	SAFE_INTERNET_CLOSE_HANDLE(m_hConnect);
	SAFE_INTERNET_CLOSE_HANDLE(m_hInstance);

	m_url_str.Empty();
	m_host.Empty();
	m_path.Empty();

	m_nPort   = 0;
	m_nScheme = INTERNET_SCHEME_HTTP;

	m_header.Empty();
	m_contentType.Empty();
	m_lenght = 0;

	m_bRequestComplete = TRUE;
}

HRESULT CHTTPAsync::Connect(LPCWSTR lpszURL, DWORD dwTimeOut/* = INFINITE*/, LPCWSTR lpszCustomHeader/* = L""*/)
{
	Close();

	CUrlParser urlParser;
	if (!urlParser.Parse(lpszURL)) {
		return E_INVALIDARG;
	}
	if (urlParser.GetScheme() != INTERNET_SCHEME_HTTP && urlParser.GetScheme() != INTERNET_SCHEME_HTTPS) {
		return E_FAIL;
	}

	m_url_str = lpszURL;
	m_host    = urlParser.GetHostName();
	m_path    = CString(urlParser.GetUrlPath()) + CString(urlParser.GetExtraInfo());
	m_nPort   = urlParser.GetPortNumber();
	m_nScheme = urlParser.GetScheme();

	CString lpszAgent;
	lpszAgent.Format(L"MPCBE.%S", MPC_VERSION_SVN_STR);
	m_hInstance = InternetOpenW(lpszAgent,
							    INTERNET_OPEN_TYPE_PRECONFIG,
							    nullptr,
							    nullptr,
							    INTERNET_FLAG_ASYNC);
	CheckPointer(m_hInstance, E_FAIL);

	if (InternetSetStatusCallbackW(m_hInstance, (INTERNET_STATUS_CALLBACK)&Callback) == INTERNET_INVALID_STATUS_CALLBACK) {
		return E_FAIL;
	}

	static bool bSetMaxConnections = false;
	if (!bSetMaxConnections) {
		bSetMaxConnections = true;

		DWORD value = 0;
		DWORD size = sizeof(DWORD);
		if (InternetQueryOptionW(nullptr, INTERNET_OPTION_MAX_CONNS_PER_SERVER, &value, &size) && value < 10) {
			value = 10;
			InternetSetOptionW(nullptr, INTERNET_OPTION_MAX_CONNS_PER_SERVER, &value, size);
		}

		if (InternetQueryOptionW(nullptr, INTERNET_OPTION_MAX_CONNS_PER_1_0_SERVER, &value, &size) && value < 10) {
			value = 10;
			InternetSetOptionW(nullptr, INTERNET_OPTION_MAX_CONNS_PER_1_0_SERVER, &value, size);
		}
	}

	m_context = Context::CONTEXT_CONNECT;

	m_hConnect = InternetConnectW(m_hInstance,
								  m_host,
								  m_nPort,
								  urlParser.GetUserName(),
								  urlParser.GetPassword(),
								  INTERNET_SERVICE_HTTP,
								  INTERNET_FLAG_KEEP_CONNECTION | INTERNET_FLAG_NO_CACHE_WRITE,
								  (DWORD_PTR)this);
	if (m_hConnect == nullptr) {
		CheckLastError(L"InternetConnectW()", E_FAIL);

		if (WaitForSingleObject(m_hConnectedEvent, dwTimeOut) == WAIT_TIMEOUT) {
			return E_FAIL;
		}
	}

	CheckPointer(m_hConnect, E_FAIL);

	if (SendRequest(lpszCustomHeader, dwTimeOut) != S_OK) {
		return E_FAIL;
	}

	m_header = QueryInfoStr(HTTP_QUERY_RAW_HEADERS_CRLF);
	m_header.Trim(L"\r\n ");
#if 0
	DLog(L"CHTTPAsync::Connect() : return header:\n%s", m_header);
#endif

	m_contentType = QueryInfoStr(HTTP_QUERY_CONTENT_TYPE);

	const CString queryInfo = QueryInfoStr(HTTP_QUERY_CONTENT_LENGTH);
	if (!queryInfo.IsEmpty()) {
		QWORD val = 0;
		if (1 == swscanf_s(queryInfo, L"%I64u", &val)) {
			m_lenght = val;
		}
	}

	return S_OK;
}

HRESULT CHTTPAsync::SendRequest(LPCWSTR lpszCustomHeader/* = L""*/, DWORD dwTimeOut/* = INFINITE*/)
{
	CheckPointer(m_hConnect, E_FAIL);

	std::unique_lock<std::mutex> lock(m_mutexRequest);

	if (!m_bRequestComplete) {
		DLog(L"CHTTPAsync::SendRequest() : previous request has not completed, exit");
		return S_FALSE;
	}

	ResetEvent(m_hRequestOpenedEvent);
	ResetEvent(m_hRequestCompleteEvent);

	SAFE_INTERNET_CLOSE_HANDLE(m_hRequest);

	m_context = Context::CONTEXT_REQUEST;

	DWORD dwFlags = INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_KEEP_CONNECTION;
	if (m_nScheme == INTERNET_SCHEME_HTTPS) {
		dwFlags |= (INTERNET_FLAG_SECURE | INTERNET_FLAG_IGNORE_CERT_CN_INVALID | INTERNET_FLAG_IGNORE_CERT_DATE_INVALID);
	}

	m_hRequest = HttpOpenRequestW(m_hConnect,
								  L"GET",
								  m_path,
								  nullptr,
								  nullptr,
								  nullptr,
								  dwFlags,
								  (DWORD_PTR)this);
	if (m_hRequest == nullptr) {
		CheckLastError(L"HttpOpenRequestW()", E_FAIL);

		if (WaitForSingleObject(m_hRequestOpenedEvent, dwTimeOut) == WAIT_TIMEOUT) {
			DLog(L"CHTTPAsync::SendRequest() : HttpOpenRequestW() - %u ms time out reached, exit", dwTimeOut);
			m_bRequestComplete = FALSE;
			return E_FAIL;
		}
	}

	CheckPointer(m_hRequest, E_FAIL);

	CString lpszHeaders = L"Accept: */*\r\n";
	lpszHeaders += lpszCustomHeader;
	for (;;) {
		if (!HttpSendRequestW(m_hRequest,
							  lpszHeaders,
							  lpszHeaders.GetLength(),
							  nullptr,
							  0)) {
			CheckLastError(L"HttpSendRequestW()", E_FAIL);

			if (WaitForSingleObject(m_hRequestCompleteEvent, dwTimeOut) == WAIT_TIMEOUT) {
				DLog(L"CHTTPAsync::SendRequest() : HttpSendRequestW() - %u ms time out reached, exit", dwTimeOut);
				m_bRequestComplete = FALSE;
				return S_FALSE;
			}
		}

		const DWORD dwStatusCode = QueryInfoDword(HTTP_QUERY_STATUS_CODE);
		if (dwStatusCode == HTTP_STATUS_PROXY_AUTH_REQ) {
			DWORD dwFlags = FLAGS_ERROR_UI_FILTER_FOR_ERRORS | FLAGS_ERROR_UI_FLAGS_CHANGE_OPTIONS | FLAGS_ERROR_UI_FLAGS_GENERATE_DATA;
			const DWORD ret = InternetErrorDlg(GetDesktopWindow(),
											   m_hRequest,
											   ERROR_INTERNET_INCORRECT_PASSWORD,
											   dwFlags,
											   nullptr);
			if (ret == ERROR_INTERNET_FORCE_RETRY) {
				continue;
			}

			return E_FAIL;
		} else if (dwStatusCode != HTTP_STATUS_OK && dwStatusCode != HTTP_STATUS_PARTIAL_CONTENT) {
			return E_FAIL;
		}

		break;
	}

	return S_OK;
}

HRESULT CHTTPAsync::Read(PBYTE pBuffer, DWORD dwSizeToRead, LPDWORD dwSizeRead, DWORD dwTimeOut/* = INFINITE*/)
{
	CheckPointer(m_hRequest, E_FAIL);

	std::unique_lock<std::mutex> lock(m_mutexRequest);

	if (!m_bRequestComplete) {
		DLog(L"CHTTPAsync::Read() : previous request has not completed, exit");
		return S_FALSE;
	}

	m_context = Context::CONTEXT_REQUEST;

	DWORD _dwSizeRead = 0;
	DWORD _dwSizeToRead = dwSizeToRead;

	while (_dwSizeToRead) {
		INTERNET_BUFFERS InetBuff = { sizeof(InetBuff) };
		InetBuff.lpvBuffer = &pBuffer[_dwSizeRead];
		InetBuff.dwBufferLength = _dwSizeToRead;

		if (!InternetReadFileExW(m_hRequest,
			&InetBuff,
			IRF_ASYNC,
			(DWORD_PTR)this)) {
			CheckLastError(L"InternetReadFileExW()", E_FAIL);

			if (WaitForSingleObject(m_hRequestCompleteEvent, dwTimeOut) == WAIT_TIMEOUT) {
				DLog(L"CHTTPAsync::Read() : InternetReadFileExW() - %u ms time out reached, exit", dwTimeOut);
				m_bRequestComplete = FALSE;
				return S_FALSE;
			}
		}

		if (!InetBuff.dwBufferLength) {
			break;
		}

		_dwSizeRead += InetBuff.dwBufferLength;
		_dwSizeToRead -= InetBuff.dwBufferLength;
	};

	if (dwSizeRead) {
		*dwSizeRead = _dwSizeRead;
	}

	return _dwSizeRead ? S_OK : S_FALSE;
}

CString CHTTPAsync::GetHeader() const
{
	return m_header;
}

CString CHTTPAsync::GetContentType() const
{
	return m_contentType;
}

QWORD CHTTPAsync::GetLenght() const
{
	return m_lenght;
}

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

#pragma once

#include <wininet.h>
#include <mutex>
#include "UrlParser.h"

class CHTTPAsync
{
protected:
	std::mutex m_mutexRequest;

	enum Context {
		CONTEXT_INITIAL = -1,
		CONTEXT_CONNECT,
		CONTEXT_REQUEST
	};
	Context m_context = CONTEXT_INITIAL;

	HANDLE m_hConnectedEvent       = INVALID_HANDLE_VALUE;
	HANDLE m_hRequestOpenedEvent   = INVALID_HANDLE_VALUE;
	HANDLE m_hRequestCompleteEvent = INVALID_HANDLE_VALUE;
	BOOL m_bRequestComplete        = TRUE;

	HINTERNET m_hInstance = nullptr;
	HINTERNET m_hConnect  = nullptr;
	HINTERNET m_hRequest  = nullptr;

	CString m_url_str;
	CString m_host;
	CString m_path;

	INTERNET_PORT m_nPort     = 0;
	INTERNET_SCHEME m_nScheme = INTERNET_SCHEME_HTTP;

	CString m_header;
	CString m_contentType;
	QWORD m_lenght = 0;

	static void CALLBACK Callback(__in HINTERNET hInternet,
								  __in_opt DWORD_PTR dwContext,
								  __in DWORD dwInternetStatus,
								  __in_opt LPVOID lpvStatusInformation,
								  __in DWORD dwStatusInformationLength);

	CString QueryInfoStr(DWORD dwInfoLevel) const;
	DWORD QueryInfoDword(DWORD dwInfoLevel) const;

public:
	CHTTPAsync();
	virtual ~CHTTPAsync();

	void Close();

	HRESULT Connect(LPCWSTR lpszURL, DWORD dwTimeOut = INFINITE, LPCWSTR lpszCustomHeader = L"");
	HRESULT SendRequest(LPCWSTR lpszCustomHeader = L"", DWORD dwTimeOut = INFINITE);
	HRESULT Read(PBYTE pBuffer, DWORD dwSizeToRead, LPDWORD dwSizeRead, DWORD dwTimeOut = INFINITE);

	CString GetHeader() const;
	CString GetContentType() const;
	QWORD GetLenght() const;
};


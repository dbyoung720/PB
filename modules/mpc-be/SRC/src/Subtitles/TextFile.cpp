/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2019 see Authors.txt
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
#include <atlbase.h>
#include <afxinet.h>
#include "TextFile.h"
#include <Utf8.h>
#include "../DSUtil/FileHandle.h"
#include "../DSUtil/HTTPAsync.h"

#define TEXTFILE_BUFFER_SIZE (64 * 1024)

CTextFile::CTextFile(enc encoding/* = ASCII*/, enc defaultencoding/* = ASCII*/)
	: m_encoding(encoding)
	, m_defaultencoding(defaultencoding)
	, m_offset(0)
	, m_posInFile(0)
	, m_posInBuffer(0)
	, m_nInBuffer(0)
{
	m_buffer.Allocate(TEXTFILE_BUFFER_SIZE);
	m_wbuffer.Allocate(TEXTFILE_BUFFER_SIZE);
}

bool CTextFile::Open(LPCWSTR lpszFileName)
{
	CFileException fex;
	for (unsigned attempt = 1;; attempt++) {
		if (!__super::Open(lpszFileName, modeRead | typeBinary | shareDenyNone, &fex)) {
			if (fex.m_cause == CFileException::sharingViolation) {
				if (attempt <= 5) {
					Sleep(20);
					continue;
				}
			}
			return false;
		}

		break;
	}

	m_offset = 0;
	m_nInBuffer = m_posInBuffer = 0;

	if (__super::GetLength() >= 2) {
		WORD w;
		if (sizeof(w) != Read(&w, sizeof(w))) {
			return Close(), false;
		}

		if (w == 0xfeff) {
			m_encoding = LE16;
			m_offset = 2;
		} else if (w == 0xfffe) {
			m_encoding = BE16;
			m_offset = 2;
		} else if (w == 0xbbef && __super::GetLength() >= 3) {
			BYTE b;
			if (sizeof(b) != Read(&b, sizeof(b))) {
				return Close(), false;
			}

			if (b == 0xbf) {
				m_encoding = UTF8;
				m_offset = 3;
			}
		}
	}

	if (m_encoding == ASCII) {
		if (!ReopenAsText()) {
			return false;
		}
	} else if (m_offset == 0) { // No BOM detected, ensure the file is read from the beginning
		Seek(0, begin);
	} else {
		m_posInFile = __super::GetPosition();
	}

	return true;
}

bool CTextFile::ReopenAsText()
{
	CString strFileName = m_strFileName;

	__super::Close();

	return !!__super::Open(strFileName, modeRead | typeText | shareDenyNone);
}

bool CTextFile::Save(LPCWSTR lpszFileName, enc e)
{
	if (!__super::Open(lpszFileName, modeCreate | modeWrite | shareDenyWrite | (e == ASCII ? typeText : typeBinary))) {
		return false;
	}

	if (e == UTF8) {
		BYTE b[3] = {0xef, 0xbb, 0xbf};
		Write(b, sizeof(b));
	} else if (e == LE16) {
		BYTE b[2] = {0xff, 0xfe};
		Write(b, sizeof(b));
	} else if (e == BE16) {
		BYTE b[2] = {0xfe, 0xff};
		Write(b, sizeof(b));
	}

	m_encoding = e;

	return true;
}

void CTextFile::SetEncoding(enc e)
{
	m_encoding = e;
}

CTextFile::enc CTextFile::GetEncoding()
{
	return m_encoding;
}

bool CTextFile::IsUnicode()
{
	return m_encoding == UTF8 || m_encoding == LE16 || m_encoding == BE16;
}

// CFile

CString CTextFile::GetFilePath() const
{
	// to avoid a CException coming from CTime
	return m_strFileName; // __super::GetFilePath();
}

// CStdioFile

ULONGLONG CTextFile::GetPosition() const
{
	return (CStdioFile::GetPosition() - m_offset - (m_nInBuffer - m_posInBuffer));
}

ULONGLONG CTextFile::GetLength() const
{
	return (CStdioFile::GetLength() - m_offset);
}

ULONGLONG CTextFile::Seek(LONGLONG lOff, UINT nFrom)
{
	ULONGLONG newPos;

	// Try to reuse the buffer if any
	if (m_nInBuffer > 0) {
		const LONGLONG pos = GetPosition();
		const LONGLONG len = GetLength();

		switch (nFrom) {
			default:
			case begin:
				break;
			case current:
				lOff = pos + lOff;
				break;
			case end:
				lOff = len - lOff;
				break;
		}

		lOff = std::clamp(lOff, 0LL, len);

		m_posInBuffer += lOff - pos;
		if (m_posInBuffer < 0 || m_posInBuffer >= m_nInBuffer) {
			// If we would have to end up out of the buffer, we just reset it and seek normally
			m_nInBuffer = m_posInBuffer = 0;
			newPos = CStdioFile::Seek(lOff + m_offset, begin) - m_offset;
		} else { // If we can reuse the buffer, we have nothing special to do
			newPos = ULONGLONG(lOff);
		}
	} else { // No buffer, we can use the base implementation
		if (nFrom == begin) {
			lOff += m_offset;
		}
		newPos = CStdioFile::Seek(lOff, nFrom) - m_offset;
	}

	m_posInFile = newPos + m_offset + (m_nInBuffer - m_posInBuffer);

	return newPos;
}

void CTextFile::WriteString(LPCSTR lpsz/*CStringA str*/)
{
	CStringA str(lpsz);

	if (m_encoding == ASCII) {
		__super::WriteString(AToT(str));
	} else if (m_encoding == ANSI) {
		str.Replace("\n", "\r\n");
		Write((LPCSTR)str, str.GetLength());
	} else if (m_encoding == UTF8) {
		WriteString(AToT(str));
	} else if (m_encoding == LE16) {
		WriteString(AToT(str));
	} else if (m_encoding == BE16) {
		WriteString(AToT(str));
	}
}

void CTextFile::WriteString(LPCWSTR lpsz/*CStringW str*/)
{
	CString str(lpsz);

	if (m_encoding == ASCII) {
		__super::WriteString(str);
	} else if (m_encoding == ANSI) {
		str.Replace(L"\n", L"\r\n");
		CStringA stra(str); // TODO: codepage
		Write((LPCSTR)stra, stra.GetLength());
	} else if (m_encoding == UTF8) {
		str.Replace(L"\n", L"\r\n");
		for (unsigned int i = 0, l = str.GetLength(); i < l; i++) {
			DWORD c = (WORD)str[i];

			if (c < 0x80) { // 0xxxxxxx
				Write(&c, 1);
			} else if (c < 0x800) { // 110xxxxx 10xxxxxx
				c = 0xc080 | ((c << 2) & 0x1f00) | (c & 0x003f);
				Write((BYTE*)&c + 1, 1);
				Write(&c, 1);
			} else if (c < 0xFFFF) { // 1110xxxx 10xxxxxx 10xxxxxx
				c = 0xe08080 | ((c << 4) & 0x0f0000) | ((c << 2) & 0x3f00) | (c & 0x003f);
				Write((BYTE*)&c + 2, 1);
				Write((BYTE*)&c + 1, 1);
				Write(&c, 1);
			} else {
				c = '?';
				Write(&c, 1);
			}
		}
	} else if (m_encoding == LE16) {
		str.Replace(L"\n", L"\r\n");
		Write((LPCWSTR)str, str.GetLength() * 2);
	} else if (m_encoding == BE16) {
		str.Replace(L"\n", L"\r\n");
		for (unsigned int i = 0, l = str.GetLength(); i < l; i++) {
			str.SetAt(i, ((str[i] >> 8) & 0x00ff) | ((str[i] << 8) & 0xff00));
		}
		Write((LPCWSTR)str, str.GetLength() * 2);
	}
}

bool CTextFile::FillBuffer()
{
	if (m_posInBuffer < m_nInBuffer) {
		m_nInBuffer -= m_posInBuffer;
		memcpy(m_buffer, &m_buffer[m_posInBuffer], (size_t)m_nInBuffer * sizeof(char));
	} else {
		m_nInBuffer = 0;
	}
	m_posInBuffer = 0;

	UINT nBytesRead = Read(&m_buffer[m_nInBuffer], UINT(TEXTFILE_BUFFER_SIZE - m_nInBuffer) * sizeof(char));
	if (nBytesRead) {
		m_nInBuffer += nBytesRead;
	}
	m_posInFile = __super::GetPosition();

	return !nBytesRead;
}

ULONGLONG CTextFile::GetPositionFastBuffered() const
{
	return (m_posInFile - m_offset - (m_nInBuffer - m_posInBuffer));
}

BOOL CTextFile::ReadString(CStringA& str)
{
	bool fEOF = true;

	str.Truncate(0);

	if (m_encoding == ASCII) {
		CString s;
		fEOF = !__super::ReadString(s);
		str = TToA(s);
		// For consistency with other encodings, we continue reading
		// the file even when a NUL char is encountered.
		char c;
		while (fEOF && (Read(&c, sizeof(c)) == sizeof(c))) {
			str += c;
			fEOF = !__super::ReadString(s);
			str += TToA(s);
		}
	} else if (m_encoding == ANSI) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;

			for (nCharsRead = 0; m_posInBuffer + nCharsRead < m_nInBuffer; nCharsRead++) {
				if (m_buffer[m_posInBuffer + nCharsRead] == '\n') {
					break;
				} else if (m_buffer[m_posInBuffer + nCharsRead] == '\r') {
					break;
				}
			}

			str.Append(&m_buffer[m_posInBuffer], nCharsRead);

			m_posInBuffer += nCharsRead;
			while (m_posInBuffer < m_nInBuffer && m_buffer[m_posInBuffer] == '\r') {
				m_posInBuffer++;
			}
			if (m_posInBuffer < m_nInBuffer && m_buffer[m_posInBuffer] == '\n') {
				bLineEndFound = true; // Stop at end of line
				m_posInBuffer++;
			}

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	} else if (m_encoding == UTF8) {
		ULONGLONG lineStartPos = GetPositionFastBuffered();
		bool bValid = true;
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;
			char* abuffer = (char*)(WCHAR*)m_wbuffer;

			for (nCharsRead = 0; m_posInBuffer < m_nInBuffer; m_posInBuffer++, nCharsRead++) {
				if (Utf8::isSingleByte(m_buffer[m_posInBuffer])) { // 0xxxxxxx
					abuffer[nCharsRead] = m_buffer[m_posInBuffer] & 0x7f;
				} else if (Utf8::isFirstOfMultibyte(m_buffer[m_posInBuffer])) {
					int nContinuationBytes = Utf8::continuationBytes(m_buffer[m_posInBuffer]);
					bValid = (nContinuationBytes <= 2);

					// We don't support characters wider than 16 bits
					if (bValid) {
						if (m_posInBuffer + nContinuationBytes >= m_nInBuffer) {
							// If we are at the end of the file, the buffer won't be full
							// and we won't be able to read any more continuation bytes.
							bValid = (m_nInBuffer == TEXTFILE_BUFFER_SIZE);
							break;
						} else {
							for (int j = 1; j <= nContinuationBytes; j++) {
								if (!Utf8::isContinuation(m_buffer[m_posInBuffer + j])) {
									bValid = false;
								}
							}

							switch (nContinuationBytes) {
								case 0: // 0xxxxxxx
									abuffer[nCharsRead] = m_buffer[m_posInBuffer] & 0x7f;
									break;
								case 1: // 110xxxxx 10xxxxxx
								case 2: // 1110xxxx 10xxxxxx 10xxxxxx
									// Unsupported for non unicode strings
									abuffer[nCharsRead] = '?';
									break;
							}
							m_posInBuffer += nContinuationBytes;
						}
					}
				} else {
					bValid = false;
				}

				if (!bValid) {
					abuffer[nCharsRead] = '?';
					m_posInBuffer++;
					nCharsRead++;
					break;
				} else if (abuffer[nCharsRead] == '\n') {
					bLineEndFound = true; // Stop at end of line
					m_posInBuffer++;
					break;
				} else if (abuffer[nCharsRead] == '\r') {
					nCharsRead--; // Skip \r
				}
			}

			if (bValid || m_offset) {
				str.Append(abuffer, nCharsRead);

				if (!bLineEndFound) {
					bLineEndFound = FillBuffer();
					if (!nCharsRead) {
						fEOF = bLineEndFound;
					}
				}
			} else {
				// Switch to text and read again
				m_encoding = m_defaultencoding;
				// Stop using the buffer
				m_posInBuffer = m_nInBuffer = 0;

				fEOF = !ReopenAsText();

				if (!fEOF) {
					// Seek back to the beginning of the line where we stopped
					Seek(lineStartPos, begin);

					fEOF = !ReadString(str);
				}
			}
		} while (bValid && !bLineEndFound);
	} else if (m_encoding == LE16) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;
			WCHAR* wbuffer = (WCHAR*)&m_buffer[m_posInBuffer];
			char* abuffer = (char*)(WCHAR*)m_wbuffer;

			for (nCharsRead = 0; m_posInBuffer + 1 < m_nInBuffer; nCharsRead++, m_posInBuffer += sizeof(WCHAR)) {
				if (wbuffer[nCharsRead] == L'\n') {
					break; // Stop at end of line
				} else if (wbuffer[nCharsRead] == L'\r') {
					break; // Skip \r
				} else if (!(wbuffer[nCharsRead] & 0xff00)) {
					abuffer[nCharsRead] = char(wbuffer[nCharsRead] & 0xff);
				} else {
					abuffer[nCharsRead] = '?';
				}
			}

			str.Append(abuffer, nCharsRead);

			while (m_posInBuffer + 1 < m_nInBuffer && wbuffer[nCharsRead] == L'\r') {
				nCharsRead++;
				m_posInBuffer += sizeof(WCHAR);
			}
			if (m_posInBuffer + 1 < m_nInBuffer && wbuffer[nCharsRead] == L'\n') {
				bLineEndFound = true; // Stop at end of line
				nCharsRead++;
				m_posInBuffer += sizeof(WCHAR);
			}

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	} else if (m_encoding == BE16) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;
			char* abuffer = (char*)(WCHAR*)m_wbuffer;

			for (nCharsRead = 0; m_posInBuffer + 1 < m_nInBuffer; nCharsRead++, m_posInBuffer += sizeof(WCHAR)) {
				if (!m_buffer[m_posInBuffer]) {
					abuffer[nCharsRead] = m_buffer[m_posInBuffer + 1];
				} else {
					abuffer[nCharsRead] = '?';
				}

				if (abuffer[nCharsRead] == '\n') {
					bLineEndFound = true; // Stop at end of line
					m_posInBuffer += sizeof(WCHAR);
					break;
				} else if (abuffer[nCharsRead] == L'\r') {
					nCharsRead--; // Skip \r
				}
			}

			str.Append(abuffer, nCharsRead);

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	}

	return !fEOF;
}

BOOL CTextFile::ReadString(CStringW& str)
{
	bool fEOF = true;

	str.Truncate(0);

	if (m_encoding == ASCII) {
		CString s;
		fEOF = !__super::ReadString(s);
		str = s;
		// For consistency with other encodings, we continue reading
		// the file even when a NUL char is encountered.
		char c;
		while (fEOF && (Read(&c, sizeof(c)) == sizeof(c))) {
			str += c;
			fEOF = !__super::ReadString(s);
			str += s;
		}
	} else if (m_encoding == ANSI) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;

			for (nCharsRead = 0; m_posInBuffer + nCharsRead < m_nInBuffer; nCharsRead++) {
				if (m_buffer[m_posInBuffer + nCharsRead] == '\n') {
					break;
				} else if (m_buffer[m_posInBuffer + nCharsRead] == '\r') {
					break;
				}
			}

			// TODO: codepage
			str.Append(CStringW(&m_buffer[m_posInBuffer], nCharsRead));

			m_posInBuffer += nCharsRead;
			while (m_posInBuffer < m_nInBuffer && m_buffer[m_posInBuffer] == '\r') {
				m_posInBuffer++;
			}
			if (m_posInBuffer < m_nInBuffer && m_buffer[m_posInBuffer] == '\n') {
				bLineEndFound = true; // Stop at end of line
				m_posInBuffer++;
			}

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	} else if (m_encoding == UTF8) {
		ULONGLONG lineStartPos = GetPositionFastBuffered();
		bool bValid = true;
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;

			for (nCharsRead = 0; m_posInBuffer < m_nInBuffer; m_posInBuffer++, nCharsRead++) {
				if (Utf8::isSingleByte(m_buffer[m_posInBuffer])) { // 0xxxxxxx
					m_wbuffer[nCharsRead] = m_buffer[m_posInBuffer] & 0x7f;
				} else if (Utf8::isFirstOfMultibyte(m_buffer[m_posInBuffer])) {
					int nContinuationBytes = Utf8::continuationBytes(m_buffer[m_posInBuffer]);
					bValid = true;

					if (m_posInBuffer + nContinuationBytes >= m_nInBuffer) {
						// If we are at the end of the file, the buffer won't be full
						// and we won't be able to read any more continuation bytes.
						bValid = (m_nInBuffer == TEXTFILE_BUFFER_SIZE);
						break;
					} else {
						for (int j = 1; j <= nContinuationBytes; j++) {
							if (!Utf8::isContinuation(m_buffer[m_posInBuffer + j])) {
								bValid = false;
							}
						}

						switch (nContinuationBytes) {
							case 0: // 0xxxxxxx
								m_wbuffer[nCharsRead] = m_buffer[m_posInBuffer] & 0x7f;
								break;
							case 1: // 110xxxxx 10xxxxxx
								m_wbuffer[nCharsRead] = (m_buffer[m_posInBuffer] & 0x1f) << 6 | (m_buffer[m_posInBuffer + 1] & 0x3f);
								break;
							case 2: // 1110xxxx 10xxxxxx 10xxxxxx
								m_wbuffer[nCharsRead] = (m_buffer[m_posInBuffer] & 0x0f) << 12 | (m_buffer[m_posInBuffer + 1] & 0x3f) << 6 | (m_buffer[m_posInBuffer + 2] & 0x3f);
								break;
							case 3: // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
								{
									const auto* Z = &m_buffer[m_posInBuffer];
									const auto u32 = ((uint32_t)(*Z & 0x0F) << 18) | ((uint32_t)(*(Z + 1) & 0x3F) << 12) | ((uint32_t)(*(Z + 2) & 0x3F) << 6) | ((uint32_t) * (Z + 3) & 0x3F);
									if (u32 <= UINT16_MAX) {
										m_wbuffer[nCharsRead] = (wchar_t)u32;
									} else {
										m_wbuffer[nCharsRead++] = (wchar_t)((((u32 - 0x010000) & 0x000FFC00) >> 10) | 0xD800);
										m_wbuffer[nCharsRead]   = (wchar_t)((u32 & 0x000003FF) | 0xDC00);
									}
								}
								break;
						}
						m_posInBuffer += nContinuationBytes;
					}
				} else {
					bValid = false;
				}

				if (!bValid) {
					m_wbuffer[nCharsRead] = L'?';
					m_posInBuffer++;
					nCharsRead++;
					break;
				} else if (m_wbuffer[nCharsRead] == L'\n') {
					bLineEndFound = true; // Stop at end of line
					m_posInBuffer++;
					break;
				} else if (m_wbuffer[nCharsRead] == L'\r') {
					nCharsRead--; // Skip \r
				}
			}

			if (bValid || m_offset) {
				str.Append(m_wbuffer, nCharsRead);

				if (!bLineEndFound) {
					bLineEndFound = FillBuffer();
					if (!nCharsRead) {
						fEOF = bLineEndFound;
					}
				}
			} else {
				// Switch to text and read again
				m_encoding = m_defaultencoding;
				// Stop using the buffer
				m_posInBuffer = m_nInBuffer = 0;

				fEOF = !ReopenAsText();

				if (!fEOF) {
					// Seek back to the beginning of the line where we stopped
					Seek(lineStartPos, begin);

					fEOF = !ReadString(str);
				}
			}
		} while (bValid && !bLineEndFound);
	} else if (m_encoding == LE16) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;
			WCHAR* wbuffer = (WCHAR*)&m_buffer[m_posInBuffer];

			for (nCharsRead = 0; m_posInBuffer + 1 < m_nInBuffer; nCharsRead++, m_posInBuffer += sizeof(WCHAR)) {
				if (wbuffer[nCharsRead] == L'\n') {
					break; // Stop at end of line
				} else if (wbuffer[nCharsRead] == L'\r') {
					break; // Skip \r
				}
			}

			str.Append(wbuffer, nCharsRead);

			while (m_posInBuffer + 1 < m_nInBuffer && wbuffer[nCharsRead] == L'\r') {
				nCharsRead++;
				m_posInBuffer += sizeof(WCHAR);
			}
			if (m_posInBuffer + 1 < m_nInBuffer && wbuffer[nCharsRead] == L'\n') {
				bLineEndFound = true; // Stop at end of line
				nCharsRead++;
				m_posInBuffer += sizeof(WCHAR);
			}

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	} else if (m_encoding == BE16) {
		bool bLineEndFound = false;
		fEOF = false;

		do {
			int nCharsRead;

			for (nCharsRead = 0; m_posInBuffer + 1 < m_nInBuffer; nCharsRead++, m_posInBuffer += sizeof(WCHAR)) {
				m_wbuffer[nCharsRead] = ((WCHAR(m_buffer[m_posInBuffer]) << 8) & 0xff00) | (WCHAR(m_buffer[m_posInBuffer + 1]) & 0x00ff);
				if (m_wbuffer[nCharsRead] == L'\n') {
					bLineEndFound = true; // Stop at end of line
					m_posInBuffer += sizeof(WCHAR);
					break;
				} else if (m_wbuffer[nCharsRead] == L'\r') {
					nCharsRead--; // Skip \r
				}
			}

			str.Append(m_wbuffer, nCharsRead);

			if (!bLineEndFound) {
				bLineEndFound = FillBuffer();
				if (!nCharsRead) {
					fEOF = bLineEndFound;
				}
			}
		} while (!bLineEndFound);
	}

	return !fEOF;
}

//
// CWebTextFile
//

CWebTextFile::CWebTextFile(CTextFile::enc encoding/* = ASCII*/, CTextFile::enc defaultencoding/* = ASCII*/, LONGLONG llMaxSize)
	: CTextFile(encoding, defaultencoding)
	, m_llMaxSize(llMaxSize)
{
}

CWebTextFile::~CWebTextFile()
{
	Close();
}

bool CWebTextFile::Open(LPCWSTR lpszFileName)
{
	CString fn(lpszFileName);

	if (fn.Find(L"http://") != 0 && fn.Find(L"https://") != 0) {
		return __super::Open(lpszFileName);
	}

	CHTTPAsync m_HTTPAsync;
	if (SUCCEEDED(m_HTTPAsync.Connect(lpszFileName, 5000))) {
		if (GetTemporaryFilePath(L".tmp", fn)) {
			CFile temp;
			if (!temp.Open(fn, modeCreate | modeWrite | typeBinary | shareDenyWrite)) {
				m_HTTPAsync.Close();
				return false;
			}

			BYTE buffer[1024] = {};
			DWORD dwSizeRead  = 0;
			DWORD totalSize   = 0;
			do {
				if (m_HTTPAsync.Read(buffer, 1024, &dwSizeRead) != S_OK) {
					break;
				}
				temp.Write(buffer, dwSizeRead);
				totalSize += dwSizeRead;
			} while (dwSizeRead && totalSize < m_llMaxSize);
			temp.Close();

			if (totalSize) {
				m_tempfn = fn;
			}
		}

		m_HTTPAsync.Close();
	}

	return __super::Open(m_tempfn);
}

bool CWebTextFile::Save(LPCWSTR lpszFileName, enc e)
{
	// CWebTextFile is read-only...
	ASSERT(0);
	return false;
}

void CWebTextFile::Close()
{
	if (m_pStream) {
		__super::Close();
	}

	if (!m_tempfn.IsEmpty()) {
		_wremove(m_tempfn);
		m_tempfn.Empty();
	}
}

///////////////////////////////////////////////////////////////

CString AToT(CStringA str)
{
	CString ret;
	for (int i = 0, j = str.GetLength(); i < j; i++) {
		ret += (WCHAR)(BYTE)str[i];
	}
	return ret;
}

CStringA TToA(CString str)
{
	CStringA ret;
	for (int i = 0, j = str.GetLength(); i < j; i++) {
		ret += (CHAR)(BYTE)str[i];
	}
	return ret;
}

/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2020 see Authors.txt
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

#include <atlcoll.h>
#include <list>

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
Explode(const T& str, CAtlList<T>& sl, const SEP sep, const size_t limit = 0)
{
	static_assert(sizeof(SEP) <= 2); // SEP must be char or wchar_t
	sl.RemoveAll();
	if (str.IsEmpty()) {
		return T();
	}

	for (int i = 0, j = 0; ; i = j + 1) {
		j = str.Find(sep, i);

		if (j < 0 || sl.GetCount() == limit - 1) {
			sl.AddTail(str.Mid(i).Trim());
			break;
		} else {
			sl.AddTail(str.Mid(i, j - i).Trim());
		}
	}

	return sl.GetHead();
}

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
Explode(const T& str, std::list<T>& sl, const SEP sep, const size_t limit = 0)
{
	sl.clear();
	if (str.IsEmpty()) {
		return T();
	}

	const int sep_len = T(sep).GetLength();
	for (int i = 0, j = 0; ; i = j + sep_len) {
		j = str.Find(sep, i);

		if (j < 0 || sl.size() == limit - 1) {
			sl.push_back(str.Mid(i).Trim());
			break;
		} else {
			sl.push_back(str.Mid(i, j - i).Trim());
		}
	}

	return sl.front();
}

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
ExplodeMin(const T& str, std::list<T>& sl, const SEP sep, const size_t limit = 0)
{
	Explode(str, sl, sep, limit);
	for (auto it = sl.cbegin(); it != sl.cend(); ) {
		if ((*it).IsEmpty()) {
			sl.erase(it++);
		} else {
			it++;
		}
	}
	if (sl.empty()) {
		return T();
	}

	return sl.front();
}

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
ExplodeEsc(T str,std::list<T>& sl, SEP sep, size_t limit = 0, SEP esc = '\\')
{
	sl.clear();
	if (str.IsEmpty()) {
		return T();
	}

	int split = 0;
	for (int i = 0, j = 0; ; i = j + 1) {
		j = str.Find(sep, i);
		if (j < 0) {
			break;
		}

		// Skip this separator if it is escaped
		if (j > 0 && str.GetAt(j - 1) == esc) {
			// Delete the escape character
			str.Delete(j - 1);
			continue;
		}

		if (sl.size() < limit - 1) {
			sl.push_back(str.Mid(split, j - split).Trim());

			// Save new splitting position
			split = j + 1;
		}
	}
	sl.push_back(str.Mid(split).Trim());

	return sl.front();
}

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
Implode(const std::list<T>& sl, const SEP sep)
{
	T ret;
	auto it = sl.begin();
	while (it != sl.end()) {
		ret += *it++;
		if (it != sl.end()) {
			ret += sep;
		}
	}
	return ret;
}

template<class T, typename SEP>
std::enable_if_t<(std::is_same_v<T, CStringW> || std::is_same_v<T, CStringA>), T>
ImplodeEsc(const std::list<T>& sl, const SEP sep, const SEP esc = '\\')
{
	T ret;
	T escsep = T(esc) + T(sep);
	auto it = sl.begin();
	while (it != sl.end()) {
		T str = *it++;
		str.Replace(T(sep), escsep);
		ret += str;
		if (it != sl.end()) {
			ret += sep;
		}
	}
	return ret;
}

extern DWORD    CharSetToCodePage(DWORD dwCharSet);
extern CStringA ConvertMBCS(CStringA str, DWORD SrcCharSet, DWORD DstCharSet);
extern CStringA UrlEncode(const CStringA& str_in, const bool bArg = false);
extern CStringA UrlDecode(const CStringA& str_in);
extern CString  UrlDecode(LPCWSTR lpWideCharStr);
extern CString  ExtractTag(CString tag, CMapStringToString& attribs, bool& fClosing);
extern CStringA HtmlSpecialChars(CStringA str, bool bQuotes = false);

extern CStringA WStrToUTF8(LPCWSTR lpWideCharStr);

extern CStringW ConvertToWStr(LPCSTR lpMultiByteStr, UINT CodePage);
extern CStringW UTF8ToWStr(LPCSTR lpUTF8Str);
extern CStringW AltUTF8ToWStr(LPCSTR lpUTF8Str);
extern CStringW UTF8orLocalToWStr(LPCSTR lpMultiByteStr);

void FixFilename(CStringW& str);
void EllipsisURL(CStringW& url, const int maxlen);
void EllipsisPath(CStringW& path, const int maxlen);

CString FormatNumber(const CString& szNumber, const bool bNoFractionalDigits = true);

CStringW FourccToWStr(uint32_t fourcc);

template<class T>
T& FastTrimRight(T& str)
{
	if (!str.IsEmpty()) {
		T::PCXSTR szStart = str;
		T::PCXSTR szEnd   = szStart + str.GetLength() - 1;
		T::PCXSTR szCur   = szEnd;
		for (; szCur >= szStart; szCur--) {
			if (!T::StrTraits::IsSpace(*szCur) || *szCur == 133) { // allow ellipsis character
				break;
			}
		}

		if (szCur != szEnd) {
			str.Truncate(int(szCur - szStart + 1));
		}
	}

	return str;
}

template<class T>
T& FastTrim(T& str)
{
	return FastTrimRight(str).TrimLeft();
}

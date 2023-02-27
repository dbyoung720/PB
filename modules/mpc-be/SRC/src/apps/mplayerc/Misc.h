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

bool    SetPrivilege(LPCWSTR privilege, bool bEnable = true);
bool    ExploreToFile(CString path);
BOOL    IsUserAdmin();
CString GetLastErrorMsg(LPWSTR lpszFunction, DWORD dw = GetLastError());

HICON LoadIcon(const CString& fn, bool fSmall);
bool  LoadType(const CString& fn, CString& type);
bool  LoadResource(UINT resid, CStringA& str, LPCWSTR restype);
bool  LoadResourceFile(UINT resid, BYTE** ppData, UINT& size);

WORD AssignedToCmd(UINT keyOrMouseValue, bool bIsFullScreen = false, bool bCheckMouse = true);
void SetAudioRenderer(int AudioDevNo);
void ThemeRGB(int iR, int iG, int iB, int& iRed, int& iGreen, int& iBlue);
COLORREF ThemeRGB(const int iR, const int iG, const int iB);

const LPCWSTR MonospaceFonts[] = {L"Consolas", L"Lucida Console", L"Courier New", L"" };
bool IsFontInstalled(LPCWSTR lpszFont);

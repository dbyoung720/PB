/*
 * (C) 2012-2020 see Authors.txt
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

#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
#define VC_EXTRALEAN        // Exclude rarely-used stuff from Windows headers

#include <atlbase.h>
#include <atlstr.h>
#include <atlwin.h>
#include <atlcom.h>
#include <atlctl.h>

#include "resource.h"

inline constexpr auto shellExtKeyName = L"Software\\MPC-BE.ShellExt";

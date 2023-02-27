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
#include <basestruct.h>
#include "Utils.h"
#include <cmath>

uint32_t CountBits(uint32_t v)
{
	// used code from \VirtualDub\h\vd2\system\bitmath.h (VDCountBits)
	v -= (v >> 1) & 0x55555555;
	v = ((v & 0xcccccccc) >> 2) + (v & 0x33333333);
	v = (v + (v >> 4)) & 0x0f0f0f0f;
	return (v * 0x01010101) >> 24;
}

uint32_t BitNum(uint32_t v, uint32_t b)
{
	ASSERT(b != 0 && (b & (b - 1)) == 0);
	ASSERT(v & b);

	return CountBits(v & (b - 1));
}

// code from ffmpeg
int64_t av_gcd(int64_t a, int64_t b) {
	if (b) return av_gcd(b, a%b);
	else  return a;
}

int av_reduce(int *dst_num, int *dst_den,
	int64_t num, int64_t den, int64_t max)
{
	fraction_t a0 = { 0, 1 }, a1 = { 1, 0 };
	int sign = (num < 0) ^ (den < 0);
	int64_t gcd = av_gcd(abs(num), abs(den));

	if (gcd) {
		num = abs(num) / gcd;
		den = abs(den) / gcd;
	}
	if (num <= max && den <= max) {
		a1 = { (int)num, (int)den };
		den = 0;
	}

	while (den) {
		int64_t x        = num / den;
		int64_t next_den = num - den * x;
		int64_t a2n      = x * a1.num + a0.num;
		int64_t a2d      = x * a1.den + a0.den;

		if (a2n > max || a2d > max) {
			if (a1.num) x =             (max - a0.num) / a1.num;
			if (a1.den) x = std::min(x, (max - a0.den) / a1.den);

			if (den * (2 * x * a1.den + a0.den) > num * a1.den)
				a1 = { int(x * a1.num + a0.num), int(x * a1.den + a0.den) };
			break;
		}

		a0 = a1;
		a1 = { (int)a2n, (int)a2d };
		num = den;
		den = next_den;
	}
	ASSERT(av_gcd(a1.num, a1.den) <= 1U);

	*dst_num = sign ? -a1.num : a1.num;
	*dst_den = a1.den;

	return den == 0;
}

fraction_t av_d2q(double d, int max)
{
#define LOG2  0.69314718055994530941723212145817656807550013436025
	fraction_t a;
	int exponent;
	INT64 den;
	if (isnan(d))
		return { 0,0 };
	if (fabs(d) > INT_MAX + 3LL)
		return{ d < 0 ? -1 : 1, 0 };
	exponent = std::max((int)(log(fabs(d) + 1e-20) / LOG2), 0);
	den = 1LL << (61 - exponent);
	// (int64_t)rint() and llrint() do not work with gcc on ia64 and sparc64
	av_reduce(&a.num, &a.den, floor(d * den + 0.5), den, max);
	if ((!a.num || !a.den) && d && max>0 && max<INT_MAX)
		av_reduce(&a.num, &a.den, floor(d * den + 0.5), den, INT_MAX);

	return a;
}
//

SIZE ReduceDim(double value)
{
	fraction_t a = av_d2q(value, INT_MAX);
	return{ a.num, a.den };
}

int IncreaseByGrid(int value, const int step)
{
	auto r = value % step;
	value -= r;
	return r<0 ? value : value + step;
}

int DecreaseByGrid(int value, const int step)
{
	auto r = value % step;
	value -= r;
	return r>0 ? value : value - step;
}

double IncreaseFloatByGrid(double value, const int step)
{
	if (step > 0) {
		value /= step;
	} else {
		value *= -step;
	}

	value = std::floor(value + 0.0625) + 1;

	if (step < 0) {
		value /= -step;
	} else {
		value *= step;
	}

	return value;
}

double DecreaseFloatByGrid(double value, const int step)
{
	if (step > 0) {
		value /= step;
	} else {
		value *= -step;
	}

	value = std::ceil(value - 0.0625) - 1;

	if (step < 0) {
		value /= -step;
	} else {
		value *= step;
	}

	return value;
}

bool �ngleStep90(int& angle)
{
	if (angle % 90 == 0) {
		angle %= 360;
		if (angle < 0) {
			angle += 360;
		}
		return true;
	}
	return false;
}

bool StrToInt32(const wchar_t* str, int32_t& value)
{
	wchar_t* end;
	int32_t v = wcstol(str, &end, 10);
	if (end > str) {
		value = v;
		return true;
	}
	return false;
}

bool StrToUInt32(const wchar_t* str, uint32_t& value)
{
	wchar_t* end;
	uint32_t v = wcstoul(str, &end, 10);
	if (end > str) {
		value = v;
		return true;
	}
	return false;
}

bool StrToInt64(const wchar_t* str, int64_t& value)
{
	wchar_t* end;
	int64_t v = wcstoll(str, &end, 10);
	if (end > str) {
		value = v;
		return true;
	}
	return false;
}

bool StrToUInt64(const wchar_t* str, uint64_t& value)
{
	wchar_t* end;
	uint64_t v = wcstoull(str, &end, 10);
	if (end > str) {
		value = v;
		return true;
	}
	return false;
}

bool StrToDouble(const wchar_t* str, double& value)
{
	wchar_t* end;
	double v = wcstod(str, &end);
	if (end > str) {
		value = v;
		return true;
	}
	return false;
}

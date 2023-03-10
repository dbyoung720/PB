/*
 * (C) 2014-2020 see Authors.txt
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

class CAudioNormalizer
{
protected:
	int m_level;
	bool m_boost;
	int m_stepping, m_stepping_vol;
	int m_rising;

	std::vector<double> m_bufHQ;
	std::vector<double> m_smpHQ;

	DWORD m_predictor;
	BYTE m_prediction[4096];

	int m_vol;

	int ProcessInternal(float *samples, unsigned numsamples, unsigned nch);

public:
	CAudioNormalizer(void);
	virtual ~CAudioNormalizer(void);

	void SetParam(int Level, bool Boost, int Steping);
	int Process(float *samples, unsigned numsamples, unsigned nch);
};

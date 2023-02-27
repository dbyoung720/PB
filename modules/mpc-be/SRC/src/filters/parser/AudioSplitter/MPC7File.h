/*
 * (C) 2020 see Authors.txt
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

#include "AudioFile.h"

class CMPC7File : public CAudioFile
{
	struct mpc_frame_t {
		uint64_t pos    = 0;
		uint32_t size   = 0;
		uint8_t curbits = 0;
	};
	std::vector<mpc_frame_t> m_frames;

	uint32_t m_frames_cnt = 0;
	uint32_t m_currentframe = 0;

	CID3Tag* m_pID3Tag = nullptr;

public:
	CMPC7File();
	~CMPC7File();

	void SetProperties(IBaseFilter* pBF);

	HRESULT Open(CBaseSplitterFile* pFile);
	REFERENCE_TIME Seek(REFERENCE_TIME rt);
	int GetAudioFrame(CPacket* packet, REFERENCE_TIME rtStart);
	CString GetName() const { return L"MusePack 7"; };
};

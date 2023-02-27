/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2016 see Authors.txt
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

#include "../BaseSplitter/BaseSplitterFileEx.h"
#include "../../../DSUtil/ID3Tag.h"
#include "../../../DSUtil/ApeTag.h"

#define DEF_SYNC_SIZE 8096

class CMpaSplitterFile : public CBaseSplitterFileEx
{
	CMediaType m_mt;
	REFERENCE_TIME m_rtDuration;

	enum mode {
		none,
		mpa,
		mp4a
	};
	mode m_mode;

	mpahdr m_mpahdr;
	aachdr m_aachdr;
	__int64 m_startpos;

	__int64 m_procsize;
	CRBMap<__int64, int> m_pos2fsize;
	double m_coefficient;

	HRESULT Init();
	void AdjustDuration(int framesize);

	bool m_bIsVBR;

public:
	CMpaSplitterFile(IAsyncReader* pAsyncReader, HRESULT& hr);
	virtual ~CMpaSplitterFile();

	CID3Tag* m_pID3Tag;
	CAPETag* m_pAPETag;

	const CMediaType& GetMediaType() {
		return m_mt;
	}
	REFERENCE_TIME GetDuration() {
		return m_rtDuration;
	}

	__int64 GetStartPos() {
		return m_startpos;
	}

	bool Sync(int limit = DEF_SYNC_SIZE);
	bool Sync(int& FrameSize, REFERENCE_TIME& rtDuration, int limit = DEF_SYNC_SIZE, BOOL bExtraCheck = FALSE);
};

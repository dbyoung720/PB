/*
 * (C) 2006-2018 see Authors.txt
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

#include "BaseSub.h"

#define MAX_WINDOWS 64
class HDMV_WindowDefinition
{
public:
	SHORT              m_compositionNumber  = -1;
	SHORT              m_palette_id_ref     = -1;
	BYTE               m_nObjectNumber      = 0;
	CompositionObject* Objects[MAX_WINDOWS] = {};

	~HDMV_WindowDefinition() {
		for (int i = 0; i < MAX_WINDOWS; i++) {
			SAFE_DELETE(Objects[i]);
		}
	}

	void Reset() {
		m_compositionNumber = -1;
		m_palette_id_ref    = -1;
		m_nObjectNumber     = 0;
	}
};

class CGolombBuffer;

class CHdmvSub : public CBaseSub
{
public:
	enum HDMV_SEGMENT_TYPE {
		NO_SEGMENT       = 0xFFFF,
		PALETTE          = 0x14,
		OBJECT           = 0x15,
		PRESENTATION_SEG = 0x16,
		WINDOW_DEF       = 0x17,
		INTERACTIVE_SEG  = 0x18,
		END_OF_DISPLAY   = 0x80,
		HDMV_SUB1        = 0x81,
		HDMV_SUB2        = 0x82
	};

	struct VIDEO_DESCRIPTOR {
		SHORT nVideoWidth  = 0;
		SHORT nVideoHeight = 0;
		BYTE  bFrameRate   = 0;
	};

	struct COMPOSITION_DESCRIPTOR {
		SHORT nNumber = 0;
		BYTE  bState  = 0;
	};

	struct HDMV_CLUT {
		int           pSize   = 0;
		HDMV_PALETTE* Palette = nullptr;
	};

	CHdmvSub();
	~CHdmvSub();

	virtual POSITION       GetStartPosition(REFERENCE_TIME rt, double fps, bool CleanOld = false);
	virtual POSITION       GetNext(POSITION pos);
	virtual REFERENCE_TIME GetStart(POSITION nPos);
	virtual REFERENCE_TIME GetStop(POSITION nPos);
	virtual HRESULT        Render(SubPicDesc& spd, REFERENCE_TIME rt, RECT& bbox);
	virtual HRESULT        GetTextureSize (POSITION pos, SIZE& MaxTextureSize, SIZE& VideoSize, POINT& VideoTopLeft);
	virtual void           Reset();
	virtual void           CleanOld(REFERENCE_TIME rt);

	HRESULT ParseSample(BYTE* pData, long nLen, REFERENCE_TIME rtStart, REFERENCE_TIME rtStop);

private :

	static const REFERENCE_TIME  UNKNOWN_TIME      = _I64_MAX;

	HDMV_SEGMENT_TYPE            m_nCurSegment     = NO_SEGMENT;
	BYTE*                        m_pSegBuffer      = nullptr;
	int                          m_nTotalSegBuffer = 0;
	int                          m_nSegBufferPos   = 0;
	int                          m_nSegSize        = 0;

	int                          m_nColorNumber    = 0;

	VIDEO_DESCRIPTOR             m_VideoDescriptor;

	CAtlList<CompositionObject*> m_pObjects;
	HDMV_WindowDefinition*       m_pCurrentWindow = 0;
	CompositionObject            m_ParsedObjects[MAX_WINDOWS];

	HDMV_CLUT                    m_CLUT[256];
	HDMV_CLUT                    m_DefaultCLUT;

	void UpdateTimeStamp(REFERENCE_TIME rtStop);
	void ParsePresentationSegment(CGolombBuffer* pGBuffer, REFERENCE_TIME rtTime);
	void EnqueuePresentationSegment();
	void ParsePalette(CGolombBuffer* pGBuffer, USHORT nSize);
	void ParseObject(CGolombBuffer* pGBuffer, USHORT nUnitSize);

	void ParseVideoDescriptor(CGolombBuffer* pGBuffer, VIDEO_DESCRIPTOR* pVideoDescriptor);
	void ParseCompositionDescriptor(CGolombBuffer* pGBuffer, COMPOSITION_DESCRIPTOR* pCompositionDescriptor);
	void ParseCompositionObject(CGolombBuffer* pGBuffer, CompositionObject* pCompositionObject);

	void AllocSegment(int nSize);
};

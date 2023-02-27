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

#include "PngImage.h"

// CVolumeCtrl

class CVolumeCtrl : public CSliderCtrl
{
	DECLARE_DYNAMIC(CVolumeCtrl)

private:
	bool m_bSelfDrawn;
	bool m_bItemRedraw = false;

	CMPCPngImage m_BackGroundbm;
	CMPCPngImage m_Volumebm;

	int m_nThemeBrightness = -1;
	int m_nThemeRed = -1;
	int m_nThemeGreen = -1;
	int m_nThemeBlue = -1;

	CBitmap m_bmUnderCtrl;

	CImage m_cashedImage;
	bool m_bRedraw = true;
	bool m_bMute = false;

public:
	CVolumeCtrl(bool bSelfDrawn = true);
	virtual ~CVolumeCtrl() = default;

	bool Create(CWnd* pParentWnd);

	void IncreaseVolume(), DecreaseVolume();

	void SetPosInternal(int pos);

	int m_nUseDarkTheme;

protected:
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);

	DECLARE_MESSAGE_MAP()

public:
	afx_msg BOOL OnToolTipNotify(UINT id, NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnNMCustomdraw(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnSetFocus(CWnd* pOldWnd);
	afx_msg void HScroll(UINT nSBCode, UINT nPos);
	afx_msg BOOL OnMouseWheel(UINT nFlags, short zDelta, CPoint point);

	virtual void Invalidate(BOOL bErase = TRUE) { m_bItemRedraw = true; CSliderCtrl::Invalidate(bErase); }
};

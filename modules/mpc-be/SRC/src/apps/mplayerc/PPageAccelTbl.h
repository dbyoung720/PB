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

#include "PPageBase.h"
#include "PlayerListCtrl.h"
#include "controls/StaticLink.h"
#include "controls/WinHotkeyCtrl.h"
#include "vkCodes.h"

// CPPageAccelTbl dialog

class CPPageAccelTbl : public CPPageBase
{
	DECLARE_DYNAMIC(CPPageAccelTbl)

private:
	enum {COL_CMD, COL_KEY, COL_ID, COL_MOUSE, COL_MOUSE_FS, COL_APPCMD, COL_RMCMD, COL_RMREPCNT};

	std::vector<wmcmd> m_wmcmds;

	void UpdateKeyDupFlags();
	void UpdateMouseDupFlags();
	void UpdateMouseFSDupFlags();
	void UpdateAppcmdDupFlags();
	void UpdateRmcmdDupFlags();
	void UpdateAllDupFlags();

	int m_counter;

	struct ITEMDATA
	{
		size_t index = 0;
		DWORD flag = 0;
	};
	std::vector<std::unique_ptr<ITEMDATA>> m_pItemsData;

public:
	CPPageAccelTbl();
	virtual ~CPPageAccelTbl() = default;

	static CString MakeAccelModLabel(BYTE fVirt);
	static CString MakeAccelShortcutLabel(UINT id);
	static CString MakeAccelShortcutLabel(ACCEL& a);
	static CString MakeMouseButtonLabel(UINT mouse);
	static CString MakeAppCommandLabel(UINT id);

	enum {APPCOMMAND_LAST=APPCOMMAND_DWM_FLIP3D};

	enum { IDD = IDD_PPAGEACCELTBL };
	CPlayerListCtrl m_list;
	BOOL m_bWinLirc;
	CString m_WinLircAddr;
	CEdit m_WinLircEdit;
	CStaticLink m_WinLircLink;
	BOOL m_bUIce;
	CString m_UIceAddr;
	CEdit m_UIceEdit;
	CStaticLink m_UIceLink;
	BOOL m_bGlobalMedia;

	UINT_PTR m_nStatusTimerID, m_nFilterTimerID;

	CEdit m_FilterEdit;

protected:
	virtual void DoDataExchange(CDataExchange* pDX);
	virtual BOOL OnInitDialog();
	virtual BOOL OnApply();
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	virtual BOOL OnSetActive();
	virtual BOOL OnKillActive();

	void SetupList();
	void FilterList();

	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnBeginlabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDolabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnEndlabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBnClickedSelectAll();
	afx_msg void OnBnClickedResetSelected();
	afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
	afx_msg void OnCustomdrawList(NMHDR*, LRESULT*);
	afx_msg void OnTimer(UINT_PTR nIDEvent);

	afx_msg void OnChangeFilterEdit();

	virtual void OnCancel();
};

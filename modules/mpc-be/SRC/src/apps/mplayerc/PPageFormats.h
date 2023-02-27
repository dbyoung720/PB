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

#include <afxwin.h>
#include "PPageBase.h"
#include "PlayerListCtrl.h"

#define ShellExt   GetProgramDir() + L"MPCBEShellExt.dll"
#define ShellExt64 GetProgramDir() + L"MPCBEShellExt64.dll"

inline constexpr auto shellExtKeyName = L"Software\\MPC-BE.ShellExt";

// CPPageFormats dialog

class CPPageFormats : public CPPageBase
{
	DECLARE_DYNAMIC(CPPageFormats)

private:
	CImageList m_onoff;
	bool m_bInsufficientPrivileges;
	bool m_bFileExtChanged;

	int GetChecked(int iItem);
	void SetChecked(int iItem, int fChecked);

	enum autoplay_t {
		AP_VIDEO = 0,
		AP_MUSIC,
		AP_AUDIOCD,
		AP_DVDMOVIE,
		AP_BDMOVIE
	};

	void AddAutoPlayToRegistry(autoplay_t ap, bool fRegister);
	bool IsAutoPlayRegistered(autoplay_t ap);

	void SetListItemState(int nItem);
	static BOOL SetFileAssociation(CString strExt, CString extfile, bool bRegister);
	static CString GetOpenCommand();
	static CString GetEnqueueCommand();

	static CComPtr<IApplicationAssociationRegistration> m_pAAR;

	std::list<CString> m_lUnRegisterExts;

public:
	CPPageFormats();
	~CPPageFormats() = default;

	enum {COL_CATEGORY};

	static bool		RegisterApp();
	static bool		IsRegistered(CString ext, bool bCheckProgId = false);
	static bool		RegisterExt(CString ext, CString strLabel, filetype_t filetype, bool SetContextFiles = false, bool setAssociatedWithIcon = true);
	static bool		UnRegisterExt(CString ext);
	static HRESULT	RegisterUI();
	static bool		RegisterShellExt(LPCWSTR lpszLibrary);
	static bool		UnRegisterShellExt(LPCWSTR lpszLibrary);

	static BOOL		ShellExtExists();

	CPlayerListCtrl m_list;
	CString m_exts;
	CStatic m_autoplay;
	CButton m_apvideo;
	CButton m_apmusic;
	CButton m_apaudiocd;
	CButton m_apdvd;
	CButton m_chContextDir;
	CButton m_chContextFiles;
	CButton m_chAssociatedWithIcons;

	enum { IDD = IDD_PPAGEFORMATS };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);
	virtual BOOL OnInitDialog();
	virtual BOOL OnApply();

	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnNMClickList1(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnLvnItemchangedList1(NMHDR *pNMHDR, LRESULT *pResult);
	afx_msg void OnBeginlabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnDolabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnEndlabeleditList(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBnClickedAll();
	afx_msg void OnBnClickedVideo();
	afx_msg void OnBnClickedAudio();
	afx_msg void OnBnClickedDefault();
	afx_msg void OnBnClickedSet();
	afx_msg void OnBnClickedNone();
	afx_msg void OnBnRunAdmin();
	afx_msg void OnFilesAssocModified();
	afx_msg void OnUpdateButtonDefault(CCmdUI* pCmdUI);
	afx_msg void OnUpdateButtonSet(CCmdUI* pCmdUI);
};

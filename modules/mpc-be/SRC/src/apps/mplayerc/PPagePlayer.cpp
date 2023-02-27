/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2019 see Authors.txt
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
#include "MainFrm.h"
#include "PPagePlayer.h"
#include "../../DSUtil/Filehandle.h"

// CPPagePlayer dialog

IMPLEMENT_DYNAMIC(CPPagePlayer, CPPageBase)
CPPagePlayer::CPPagePlayer()
	: CPPageBase(CPPagePlayer::IDD, CPPagePlayer::IDD)
	, m_iMultipleInst(1)
	, m_bKeepHistory(FALSE)
	, m_bRememberDVDPos(FALSE)
	, m_bRememberFilePos(FALSE)
	, m_bSavePnSZoom(FALSE)
	, m_bRememberPlaylistItems(FALSE)
	, m_bTrayIcon(FALSE)
	, m_bShowOSD(FALSE)
	, m_bOSDFileName(FALSE)
	, m_bOSDSeekTime(FALSE)
	, m_bUseIni(FALSE)
	, m_bHideCDROMsSubMenu(FALSE)
	, m_bPriority(FALSE)
{
}

CPPagePlayer::~CPPagePlayer()
{
}

void CPPagePlayer::DoDataExchange(CDataExchange* pDX)
{
	__super::DoDataExchange(pDX);

	DDX_Radio(pDX, IDC_RADIO1,   m_iMultipleInst);
	DDX_Control(pDX, IDC_COMBO1, m_cbTitleBarPrefix);
	DDX_Control(pDX, IDC_COMBO2, m_cbSeekBarText);
	DDX_Check(pDX, IDC_CHECK3,   m_bTrayIcon);
	DDX_Check(pDX, IDC_CHECK11,  m_bSavePnSZoom);
	DDX_Check(pDX, IDC_CHECK8,   m_bUseIni);
	DDX_Check(pDX, IDC_CHECK1,   m_bKeepHistory);
	DDX_Check(pDX, IDC_CHECK10,  m_bHideCDROMsSubMenu);
	DDX_Check(pDX, IDC_CHECK9,   m_bPriority);
	DDX_Check(pDX, IDC_SHOW_OSD, m_bShowOSD);
	DDX_Check(pDX, IDC_CHECK14,  m_bOSDFileName);
	DDX_Check(pDX, IDC_CHECK15,  m_bOSDSeekTime);
	DDX_Check(pDX, IDC_DVD_POS,  m_bRememberDVDPos);
	DDX_Check(pDX, IDC_FILE_POS, m_bRememberFilePos);
	DDX_Check(pDX, IDC_CHECK2,   m_bRememberPlaylistItems);
	DDX_Control(pDX, IDC_EDIT1, m_edtRecentFiles);
	DDX_Control(pDX, IDC_SPIN1,  m_spnRecentFiles);
	DDX_Control(pDX, IDC_EDIT2,  m_edtNetworkTimeout);
	DDX_Control(pDX, IDC_SPIN2,  m_spnNetworkTimeout);
}

BEGIN_MESSAGE_MAP(CPPagePlayer, CPPageBase)
	ON_UPDATE_COMMAND_UI(IDC_DVD_POS, OnUpdatePos)
	ON_UPDATE_COMMAND_UI(IDC_FILE_POS, OnUpdatePos)
	ON_UPDATE_COMMAND_UI(IDC_EDIT1, OnUpdatePos)
	ON_UPDATE_COMMAND_UI(IDC_SPIN1, OnUpdatePos)
	ON_UPDATE_COMMAND_UI(IDC_CHECK14, OnUpdateOSD)
	ON_UPDATE_COMMAND_UI(IDC_CHECK15, OnUpdateOSD)
END_MESSAGE_MAP()

// CPPagePlayer message handlers

BOOL CPPagePlayer::OnInitDialog()
{
	__super::OnInitDialog();

	SetCursor(m_hWnd, IDC_COMBO1, IDC_HAND);

	CAppSettings& s = AfxGetAppSettings();

	m_cbTitleBarPrefix.AddString(ResStr(IDS_TEXTBAR_NOTHING));
	m_cbTitleBarPrefix.AddString(ResStr(IDS_TEXTBAR_FILENANE));
	m_cbTitleBarPrefix.AddString(ResStr(IDS_TEXTBAR_TITLE));
	m_cbTitleBarPrefix.AddString(ResStr(IDS_TEXTBAR_FULLPATH));
	CorrectComboListWidth(m_cbTitleBarPrefix);
	if (CB_ERR == m_cbTitleBarPrefix.SetCurSel(s.iTitleBarTextStyle)) {
		m_cbTitleBarPrefix.SetCurSel(TEXTBAR_FILENAME);
	}

	m_cbSeekBarText.AddString(ResStr(IDS_TEXTBAR_NOTHING));
	m_cbSeekBarText.AddString(ResStr(IDS_TEXTBAR_FILENANE));
	m_cbSeekBarText.AddString(ResStr(IDS_TEXTBAR_TITLE));
	m_cbSeekBarText.AddString(ResStr(IDS_TEXTBAR_FULLPATH));
	CorrectComboListWidth(m_cbSeekBarText);
	if (CB_ERR == m_cbSeekBarText.SetCurSel(s.iSeekBarTextStyle)) {
		m_cbSeekBarText.SetCurSel(TEXTBAR_TITLE);
	}

	m_iMultipleInst				= s.iMultipleInst;
	m_bTrayIcon					= s.bTrayIcon;
	m_bSavePnSZoom				= s.bSavePnSZoom;
	m_bUseIni					= AfxGetProfile().IsIniValid();
	m_bKeepHistory				= s.bKeepHistory;
	m_bHideCDROMsSubMenu		= s.bHideCDROMsSubMenu;
	m_bPriority					= s.dwPriority != NORMAL_PRIORITY_CLASS;
	m_bShowOSD					= s.ShowOSD.Enable;
	m_bOSDFileName				= s.ShowOSD.FileName;
	m_bOSDSeekTime				= s.ShowOSD.SeekTime;
	m_bRememberDVDPos			= s.bRememberDVDPos;
	m_bRememberFilePos			= s.bRememberFilePos;
	m_bRememberPlaylistItems	= s.bRememberPlaylistItems;

	m_edtRecentFiles = s.iRecentFilesNumber;
	m_edtRecentFiles.SetRange(APP_RECENTFILES_MIN, APP_RECENTFILES_MAX);
	m_spnRecentFiles.SetRange(APP_RECENTFILES_MIN, APP_RECENTFILES_MAX);
	m_spnRecentFiles.SetPos(s.iRecentFilesNumber);
	UDACCEL acc = {0, 5};
	m_spnRecentFiles.SetAccel(1, &acc);

	m_edtNetworkTimeout = s.iNetworkTimeout;
	m_edtNetworkTimeout.SetRange(APP_NETTIMEOUT_MIN, APP_NETTIMEOUT_MAX);
	m_spnNetworkTimeout.SetRange(APP_NETTIMEOUT_MIN, APP_NETTIMEOUT_MAX);

	UpdateData(FALSE);

	GetDlgItem(IDC_FILE_POS)->EnableWindow(s.bKeepHistory);
	GetDlgItem(IDC_DVD_POS)->EnableWindow(s.bKeepHistory);
	m_spnRecentFiles.EnableWindow(s.bKeepHistory);

	CString iniDirPath = GetProgramDir();
	HANDLE hDir = CreateFileW(iniDirPath, GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
							 OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, nullptr);
	// gray-out "Store settings in the player folder" option when we don't have writing permissions in the target directory
	GetDlgItem(IDC_CHECK8)->EnableWindow(hDir != INVALID_HANDLE_VALUE);
	CloseHandle(hDir);

	return TRUE;
}

BOOL CPPagePlayer::OnApply()
{
	UpdateData();

	CAppSettings& s = AfxGetAppSettings();
	auto pFrame = AfxGetMainFrame();

	s.iMultipleInst = m_iMultipleInst;

	int i = m_cbTitleBarPrefix.GetCurSel();
	if (s.iTitleBarTextStyle != i) {
		s.iTitleBarTextStyle = i;
		pFrame->UpdateWindowTitle();
	}
	i = m_cbSeekBarText.GetCurSel();
	if (s.iSeekBarTextStyle != i) {
		s.iSeekBarTextStyle = i;
	}

	s.bTrayIcon = !!m_bTrayIcon;
	s.bSavePnSZoom = !!m_bSavePnSZoom;
	s.bKeepHistory = !!m_bKeepHistory;
	s.bHideCDROMsSubMenu = !!m_bHideCDROMsSubMenu;
	s.dwPriority = !m_bPriority ? NORMAL_PRIORITY_CLASS : ABOVE_NORMAL_PRIORITY_CLASS;
	BOOL bShowOSDChanged = s.ShowOSD.Enable != m_bShowOSD;

	s.ShowOSD.Enable   = m_bShowOSD ? 1 : 0;
	s.ShowOSD.FileName = m_bOSDFileName ? 1 : 0;
	s.ShowOSD.SeekTime = m_bOSDSeekTime ? 1 : 0;
	if (bShowOSDChanged) {
		if (s.ShowOSD.Enable) {
			pFrame->m_OSD.Start(pFrame->m_pOSDWnd);
			pFrame->OSDBarSetPos();
			pFrame->m_OSD.ClearMessage(false);
		} else {
			pFrame->m_OSD.Stop();
		}
	}
	s.bRememberDVDPos = !!m_bRememberDVDPos;
	s.bRememberFilePos = !!m_bRememberFilePos;
	s.bRememberPlaylistItems = !!m_bRememberPlaylistItems;

	if (!m_bKeepHistory) {
		for (int i = s.MRU.GetSize() - 1; i >= 0; i--) {
			s.MRU.Remove(i);
		}

		for (int i = s.MRUDub.GetSize() - 1; i >= 0; i--) {
			s.MRUDub.Remove(i);
		}

		s.MRU.WriteList();
		s.MRUDub.WriteList();

		// Empty the "Recent" jump list
		CComPtr<IApplicationDestinations> pDests;
		HRESULT hr = pDests.CoCreateInstance(CLSID_ApplicationDestinations, nullptr, CLSCTX_INPROC_SERVER);
		if (SUCCEEDED(hr)) {
			hr = pDests->RemoveAllDestinations();
		}
	}
	if (!m_bKeepHistory || !m_bRememberDVDPos) {
		s.ClearDVDPositions();
	}
	if (!m_bKeepHistory || !m_bRememberFilePos) {
		s.ClearFilePositions();
	}

	s.iRecentFilesNumber = m_edtRecentFiles;
	s.MRU.SetSize(s.iRecentFilesNumber);
	s.MRUDub.SetSize(s.iRecentFilesNumber);

	s.iNetworkTimeout = m_edtNetworkTimeout;

	// Check if the settings location needs to be changed
	if (AfxGetProfile().IsIniValid() != !!m_bUseIni) {
		pFrame->m_wndPlaylistBar.TDeleteAllPlaylists();
		AfxGetMyApp()->ChangeSettingsLocation(!!m_bUseIni);
		pFrame->m_wndPlaylistBar.TSaveAllPlaylists();
	}

	AfxGetMainFrame()->ShowTrayIcon(s.bTrayIcon);

	::SetPriorityClass(::GetCurrentProcess(), s.dwPriority);

	GetDlgItem(IDC_FILE_POS)->EnableWindow(s.bKeepHistory);
	GetDlgItem(IDC_DVD_POS)->EnableWindow(s.bKeepHistory);
	m_spnRecentFiles.EnableWindow(s.bKeepHistory);

	return __super::OnApply();
}

void CPPagePlayer::OnUpdatePos(CCmdUI* pCmdUI)
{
	UpdateData();

	pCmdUI->Enable(!!m_bKeepHistory);
}

void CPPagePlayer::OnUpdateOSD(CCmdUI* pCmdUI)
{
	UpdateData();

	pCmdUI->Enable(!!m_bShowOSD);
}

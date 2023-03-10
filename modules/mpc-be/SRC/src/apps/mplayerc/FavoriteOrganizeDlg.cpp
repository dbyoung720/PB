/*
 * (C) 2003-2006 Gabest
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

#include "stdafx.h"
#include "MainFrm.h"
#include "ItemPropertiesDlg.h"
#include "FavoriteOrganizeDlg.h"
#include "../../DSUtil/std_helper.h"

// CFavoriteOrganizeDlg dialog

//IMPLEMENT_DYNAMIC(CFavoriteOrganizeDlg, CResizableDialog)

CFavoriteOrganizeDlg::CFavoriteOrganizeDlg(CWnd* pParent)
	: CResizableDialog(CFavoriteOrganizeDlg::IDD, pParent)
{
}

CFavoriteOrganizeDlg::~CFavoriteOrganizeDlg()
{
}

void CFavoriteOrganizeDlg::SetupList()
{
	auto& favlist = m_FavLists[m_tab.GetCurSel()];

	m_list.DeleteAllItems();

	for (const auto& fav : favlist) {
		std::list<CString> sl;
		ExplodeEsc(fav, sl, L'|', 2);

		if (sl.size() == 2) {
			int n = m_list.InsertItem(m_list.GetItemCount(), sl.front());
			m_list.SetItemData(n, (DWORD_PTR)&(fav));

			REFERENCE_TIME rt = 0;
			if (StrToInt64(sl.back(), rt) && rt > 0) {
				DVD_HMSF_TIMECODE hmsf = RT2HMSF(rt);
				CString str;
				str.Format(L"[%02u:%02u:%02u]", hmsf.bHours, hmsf.bMinutes, hmsf.bSeconds);
				m_list.SetItemText(n, 1, str);
			}
		}
	}

	UpdateColumnsSizes();
}

void CFavoriteOrganizeDlg::SaveList()
{
	auto& favlist = m_FavLists[m_tab.GetCurSel()];

	std::list<CString> sl;
	for (int i = 0; i < m_list.GetItemCount(); i++) {
		auto it = FindInListByPointer(favlist, (CString*)m_list.GetItemData(i));
		if (it == favlist.end()) {
			ASSERT(0);
			break;
		}

		std::list<CString> args;
		ExplodeEsc(*it, args, L'|', 4);
		args.front() = m_list.GetItemText(i, 0);

		sl.push_back(ImplodeEsc(args, L'|'));
	}
	favlist = sl;
}

void CFavoriteOrganizeDlg::UpdateColumnsSizes()
{
	CRect r;
	m_list.GetClientRect(r);
	m_list.SetColumnWidth(0, LVSCW_AUTOSIZE);
	m_list.SetColumnWidth(1, LVSCW_AUTOSIZE);
	m_list.SetColumnWidth(1, std::max(m_list.GetColumnWidth(1), r.Width() - m_list.GetColumnWidth(0)));
}

void CFavoriteOrganizeDlg::DoDataExchange(CDataExchange* pDX)
{
	__super::DoDataExchange(pDX);

	DDX_Control(pDX, IDC_TAB1, m_tab);
	DDX_Control(pDX, IDC_LIST2, m_list);
}

BEGIN_MESSAGE_MAP(CFavoriteOrganizeDlg, CResizableDialog)
	ON_NOTIFY(TCN_SELCHANGE, IDC_TAB1, OnTcnSelChangeTab1)
	ON_WM_DRAWITEM()
	ON_BN_CLICKED(IDC_BUTTON1, OnEditBnClicked)
	ON_UPDATE_COMMAND_UI(IDC_BUTTON1, OnUpdateEditBn)
	ON_BN_CLICKED(IDC_BUTTON2, OnDeleteBnClicked)
	ON_UPDATE_COMMAND_UI(IDC_BUTTON2, OnUpdateDeleteBn)
	ON_BN_CLICKED(IDC_BUTTON3, OnUpBnClicked)
	ON_UPDATE_COMMAND_UI(IDC_BUTTON3, OnUpdateUpBn)
	ON_BN_CLICKED(IDC_BUTTON4, OnDownBnClicked)
	ON_UPDATE_COMMAND_UI(IDC_BUTTON4, OnUpdateDownBn)
	ON_NOTIFY(TCN_SELCHANGING, IDC_TAB1, OnTcnSelChangingTab1)
	ON_BN_CLICKED(IDOK, OnBnClickedOk)
	ON_WM_ACTIVATE()
	ON_NOTIFY(LVN_ENDLABELEDIT, IDC_LIST2, OnLvnEndLabelEditList2)
	ON_NOTIFY(NM_DBLCLK, IDC_LIST2, OnPlayFavorite)
	ON_NOTIFY(LVN_KEYDOWN, IDC_LIST2, OnKeyPressed)
	ON_NOTIFY(LVN_GETINFOTIP, IDC_LIST2, OnLvnGetInfoTipList)
	ON_WM_SIZE()
END_MESSAGE_MAP()

// CFavoriteOrganizeDlg message handlers

BOOL CFavoriteOrganizeDlg::OnInitDialog()
{
	__super::OnInitDialog();

	CAppSettings& s = AfxGetAppSettings();

	m_tab.InsertItem(0, ResStr(IDS_FAVFILES));
	m_tab.InsertItem(1, ResStr(IDS_FAVDVDS));
	// m_tab.InsertItem(2, ResStr(IDS_FAVDEVICES));
	m_tab.SetCurSel(0);

	m_list.InsertColumn(0, L"");
	m_list.InsertColumn(1, L"");
	m_list.SetExtendedStyle(m_list.GetExtendedStyle() | LVS_EX_FULLROWSELECT | LVS_EX_INFOTIP);

	s.GetFav(FAV_FILE, m_FavLists[0]);
	s.GetFav(FAV_DVD, m_FavLists[1]);
	s.GetFav(FAV_DEVICE, m_FavLists[2]);

	SetupList();

	AddAnchor(IDC_TAB1, TOP_LEFT, BOTTOM_RIGHT);
	AddAnchor(IDC_LIST2, TOP_LEFT, BOTTOM_RIGHT);
	AddAnchor(IDC_BUTTON1, TOP_RIGHT);
	AddAnchor(IDC_BUTTON2, TOP_RIGHT);
	AddAnchor(IDC_BUTTON3, TOP_RIGHT);
	AddAnchor(IDC_BUTTON4, TOP_RIGHT);
	AddAnchor(IDOK, BOTTOM_RIGHT);

	EnableSaveRestore(IDS_R_DLG_ORGANIZE_FAV);

	return TRUE;
}

BOOL CFavoriteOrganizeDlg::PreTranslateMessage(MSG* pMsg)
{
	if (pMsg->message == WM_KEYDOWN && pMsg->wParam == VK_RETURN && pMsg->hwnd == m_list.GetSafeHwnd() && m_list.GetSelectedCount() > 0) {
		return FALSE;
	}

	return __super::PreTranslateMessage(pMsg);
}

void CFavoriteOrganizeDlg::OnTcnSelChangeTab1(NMHDR* pNMHDR, LRESULT* pResult)
{
	m_list.SetRedraw(FALSE);
	m_list.SetWindowPos(&wndTop, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
	SetupList();
	m_list.SetRedraw();

	*pResult = 0;
}

void CFavoriteOrganizeDlg::OnDrawItem(int nIDCtl, LPDRAWITEMSTRUCT lpDrawItemStruct)
{
	if (nIDCtl != IDC_LIST2) {
		return;
	}

	int nItem = lpDrawItemStruct->itemID;
	CRect rcItem = lpDrawItemStruct->rcItem;

	CDC* pDC = CDC::FromHandle(lpDrawItemStruct->hDC);

	CBrush b;
	if (!!m_list.GetItemState(nItem, LVIS_SELECTED)) {
		b.CreateSolidBrush(0xf1dacc);
		pDC->FillRect(rcItem, &b);
		b.DeleteObject();
		b.CreateSolidBrush(0xc56a31);
		pDC->FrameRect(rcItem, &b);
	} else {
		b.CreateSysColorBrush(COLOR_WINDOW);
		pDC->FillRect(rcItem, &b);
	}

	CString str;
	pDC->SetTextColor(0);

	str = m_list.GetItemText(nItem, 0);
	pDC->TextOut(rcItem.left + 3, (rcItem.top + rcItem.bottom - pDC->GetTextExtent(str).cy) / 2, str);
	str = m_list.GetItemText(nItem, 1);

	if (!str.IsEmpty()) {
		pDC->TextOut(rcItem.right - pDC->GetTextExtent(str).cx - 3, (rcItem.top + rcItem.bottom - pDC->GetTextExtent(str).cy) / 2, str);
	}
}

void CFavoriteOrganizeDlg::OnEditBnClicked()
{
	if (POSITION pos = m_list.GetFirstSelectedItemPosition()) {
		auto& favlist = m_FavLists[m_tab.GetCurSel()];
		int nItem = m_list.GetNextSelectedItem(pos);

		auto it = FindInListByPointer(favlist, (CString*)m_list.GetItemData(nItem));
		if (it == favlist.end()) {
			ASSERT(0);
			return;
		}

		std::list<CString> args;
		ExplodeEsc(*it, args, L'|', 4);
		if (args.size() < 4) {
			ASSERT(0);
			return;
		}

		CString& name = args.front();
		CString& path = *(std::next(args.begin(), 3));

		CItemPropertiesDlg ipd(name, path);
		if (ipd.DoModal() == IDOK) {
			m_list.SetItemText(nItem, 0, ipd.GetPropertyName());
			name = ipd.GetPropertyName();
			path = ipd.GetPropertyPath();
			const CString str = ImplodeEsc(args, L'|');
			*it = str;
		}
	}
}

void CFavoriteOrganizeDlg::OnUpdateEditBn(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_list.GetSelectedCount() == 1);
}

void CFavoriteOrganizeDlg::OnLvnEndLabelEditList2(NMHDR* pNMHDR, LRESULT* pResult)
{
	NMLVDISPINFO* pDispInfo = reinterpret_cast<NMLVDISPINFO*>(pNMHDR);

	if (pDispInfo->item.iItem >= 0 && pDispInfo->item.pszText) {
		m_list.SetItemText(pDispInfo->item.iItem, 0, pDispInfo->item.pszText);
	}

	UpdateColumnsSizes();

	*pResult = 0;
}

void CFavoriteOrganizeDlg::PlayFavorite(int nItem)
{
	auto pFrame = AfxGetMainFrame();
	switch (m_tab.GetCurSel()) {
		case 0: // Files
		{
			auto it = FindInListByPointer(m_FavLists[0], (CString*)m_list.GetItemData(nItem));
			pFrame->PlayFavoriteFile(*it);
		}
			break;
		case 1: // DVDs
		{
			auto it = FindInListByPointer(m_FavLists[1], (CString*)m_list.GetItemData(nItem));
			pFrame->PlayFavoriteDVD(*it);
		}
			break;
		case 2: // Devices
			break;
	}
}

void CFavoriteOrganizeDlg::OnPlayFavorite(NMHDR *pNMHDR, LRESULT *pResult)
{
	LPNMITEMACTIVATE pItemActivate = reinterpret_cast<LPNMITEMACTIVATE>(pNMHDR);

	if (pItemActivate->iItem >= 0) {
		PlayFavorite(pItemActivate->iItem);
	}
}

void CFavoriteOrganizeDlg::OnKeyPressed(NMHDR* pNMHDR, LRESULT* pResult)
{
	LV_KEYDOWN* pLVKeyDow = (LV_KEYDOWN*)pNMHDR;

	switch (pLVKeyDow->wVKey) {
		case VK_DELETE:
			OnDeleteBnClicked();
			*pResult = 1;
			break;
		case VK_RETURN:
			if (POSITION pos = m_list.GetFirstSelectedItemPosition()) {
				int nItem = m_list.GetNextSelectedItem(pos);
				if (nItem >= 0 && nItem < m_list.GetItemCount()) {
					PlayFavorite(nItem);
				}
			}
			*pResult = 1;
			break;
		case 'A':
			if (GetKeyState(VK_CONTROL) < 0) { // If the high-order bit is 1, the key is down; otherwise, it is up.
				m_list.SetItemState(-1, LVIS_SELECTED, LVIS_SELECTED);
			}
			*pResult = 1;
			break;
		case 'I':
			if (GetKeyState(VK_CONTROL) < 0) { // If the high-order bit is 1, the key is down; otherwise, it is up.
				for (int nItem = 0; nItem < m_list.GetItemCount(); nItem++) {
					m_list.SetItemState(nItem, ~m_list.GetItemState(nItem, LVIS_SELECTED), LVIS_SELECTED);
				}
			}
			*pResult = 1;
			break;
		default:
			*pResult = 0;
	}
}

void CFavoriteOrganizeDlg::OnDeleteBnClicked()
{
	POSITION pos;
	int nItem = -1;
	auto& favlist = m_FavLists[m_tab.GetCurSel()];

	while (pos = m_list.GetFirstSelectedItemPosition()) {
		nItem = m_list.GetNextSelectedItem(pos);
		if (nItem < 0 || nItem >= m_list.GetItemCount()) {
			return;
		}

		auto it = FindInListByPointer(favlist, (CString*)m_list.GetItemData(nItem));
		if (it != favlist.end()) {
			favlist.erase(it);
		}

		m_list.DeleteItem(nItem);
	}

	nItem = std::min(nItem, m_list.GetItemCount() - 1);
	m_list.SetItemState(nItem, LVIS_SELECTED, LVIS_SELECTED);
}

void CFavoriteOrganizeDlg::OnUpdateDeleteBn(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_list.GetSelectedCount() > 0);
}

void CFavoriteOrganizeDlg::MoveItem(int nItem, int offset)
{
	DWORD_PTR data = m_list.GetItemData(nItem);
	CString strName = m_list.GetItemText(nItem, 0);
	CString strPos = m_list.GetItemText(nItem, 1);

	m_list.DeleteItem(nItem);

	nItem += offset;

	m_list.InsertItem(nItem, strName);
	m_list.SetItemData(nItem, data);
	m_list.SetItemText(nItem, 1, strPos);
	m_list.SetItemState(nItem, LVIS_SELECTED, LVIS_SELECTED);
}

void CFavoriteOrganizeDlg::OnUpBnClicked()
{
	POSITION pos = m_list.GetFirstSelectedItemPosition();
	int nItem;

	while (pos) {
		nItem = m_list.GetNextSelectedItem(pos);

		if (nItem <= 0 || nItem >= m_list.GetItemCount()) {
			return;
		}

		MoveItem(nItem, -1);
	}
}

void CFavoriteOrganizeDlg::OnUpdateUpBn(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_list.GetSelectedCount() > 0 && !m_list.GetItemState(0, LVIS_SELECTED));
}

void CFavoriteOrganizeDlg::OnDownBnClicked()
{
	std::vector<int> selectedItems;

	POSITION pos = m_list.GetFirstSelectedItemPosition();
	while (pos) {
		int nItem = m_list.GetNextSelectedItem(pos);

		if (nItem < 0 || nItem >= m_list.GetItemCount() - 1) {
			return;
		}

		selectedItems.push_back(nItem);
	}

	for (int i = selectedItems.size() - 1; i >= 0; i--) {
		MoveItem(selectedItems[i], +1);
	}
}

void CFavoriteOrganizeDlg::OnUpdateDownBn(CCmdUI* pCmdUI)
{
	pCmdUI->Enable(m_list.GetSelectedCount() > 0 && !m_list.GetItemState(m_list.GetItemCount() - 1, LVIS_SELECTED));
}

void CFavoriteOrganizeDlg::OnTcnSelChangingTab1(NMHDR *pNMHDR, LRESULT *pResult)
{
	SaveList();

	*pResult = 0;
}

void CFavoriteOrganizeDlg::OnBnClickedOk()
{
	SaveList();

	CAppSettings& s = AfxGetAppSettings();

	s.SetFav(FAV_FILE, m_FavLists[0]);
	s.SetFav(FAV_DVD, m_FavLists[1]);
	s.SetFav(FAV_DEVICE, m_FavLists[2]);

	OnOK();
}

void CFavoriteOrganizeDlg::OnSize(UINT nType, int cx, int cy)
{
	__super::OnSize(nType, cx, cy);

	if (IsWindow(m_list)) {
		m_list.SetRedraw(FALSE);
		m_list.SetWindowPos(&wndTop, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
		UpdateColumnsSizes();
		m_list.SetRedraw();
	}
}

void CFavoriteOrganizeDlg::OnLvnGetInfoTipList(NMHDR* pNMHDR, LRESULT* pResult)
{
	LPNMLVGETINFOTIPW pGetInfoTip = reinterpret_cast<LPNMLVGETINFOTIPW>(pNMHDR);
	auto& favlist = m_FavLists[m_tab.GetCurSel()];

	auto it = FindInListByPointer(favlist, (CString*)m_list.GetItemData(pGetInfoTip->iItem));
	if (it == favlist.end()) {
		ASSERT(0);
		return;
	}

	std::list<CString> args;
	ExplodeEsc(*it, args, L'|', 4);
	if (args.size() < 4) {
		ASSERT(0);
		return;
	}

	const CString& path = *(std::next(args.begin(), 3));

	StringCchCopyW(pGetInfoTip->pszText, pGetInfoTip->cchTextMax, path);
	*pResult = 0;
}

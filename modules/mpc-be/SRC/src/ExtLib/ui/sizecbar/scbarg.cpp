/////////////////////////////////////////////////////////////////////////
//
// CSizingControlBarG           Version 2.45
//
// Created: Jan 24, 1998        Last Modified: April 16, 2010
//
// See the official site at www.datamekanix.com for documentation and
// the latest news.
//
/////////////////////////////////////////////////////////////////////////
// Copyright (C) 1998-2010 Cristi Posea. All rights reserved.
//
// This code is free for personal and commercial use, providing this 
// notice remains intact in the source files and all eventual changes are
// clearly marked with comments.
//
// No warrantee of any kind, express or implied, is included with this
// software; use at your own risk, responsibility for damages (if any) to
// anyone resulting from the use of this software rests entirely with the
// user.
//
// Send bug reports, bug fixes, enhancements, requests, flames, etc. to
// cristi@datamekanix.com .
/////////////////////////////////////////////////////////////////////////

// sizecbar.cpp : implementation file
//

#include "stdafx.h"
#include "scbarg.h"


/////////////////////////////////////////////////////////////////////////
// CSizingControlBarG

IMPLEMENT_DYNAMIC(CSizingControlBarG, baseCSizingControlBarG);

CSizingControlBarG::CSizingControlBarG()
{
    m_cyGripper = 12;
}

CSizingControlBarG::~CSizingControlBarG()
{
}

BEGIN_MESSAGE_MAP(CSizingControlBarG, baseCSizingControlBarG)
    //{{AFX_MSG_MAP(CSizingControlBarG)
    ON_WM_NCLBUTTONUP()
    ON_WM_NCHITTEST()
    //}}AFX_MSG_MAP
    ON_MESSAGE(WM_SETTEXT, OnSetText)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////
// CSizingControlBarG message handlers

/////////////////////////////////////////////////////////////////////////
// Mouse Handling
//

void CSizingControlBarG::OnNcLButtonUp(UINT nHitTest, CPoint point)
{
    if (nHitTest == HTCLOSE)
        m_pDockSite->ShowControlBar(this, FALSE, FALSE); // hide

    baseCSizingControlBarG::OnNcLButtonUp(nHitTest, point);
}

void CSizingControlBarG::NcCalcClient(LPRECT pRc, UINT nDockBarID)
{
    CRect rcBar(pRc); // save the bar rect

    // subtract edges
    baseCSizingControlBarG::NcCalcClient(pRc, nDockBarID);

    if (!HasGripper())
        return;

    CRect rc(pRc); // the client rect as calculated by the base class
    //MPC-BE custom code start
    // Work in screen coordinates before converting back to
    // client coordinates to account for possible RTL layout
    GetParent()->ClientToScreen(rcBar);
    GetParent()->ClientToScreen(rc);
    //MPC-BE custom code end

    BOOL bHorz = (nDockBarID == AFX_IDW_DOCKBAR_TOP) ||
                 (nDockBarID == AFX_IDW_DOCKBAR_BOTTOM);

    if (bHorz)
        rc.DeflateRect(ScaleX(m_cyGripper), 0, 0, 0);
    else
        rc.DeflateRect(0, ScaleY(m_cyGripper), 0, 0);

    // set position for the "x" (hide bar) button
    CPoint ptOrgBtn;
    if (bHorz)
        ptOrgBtn = CPoint(rc.left - ScaleX(m_cyGripper), rc.top);
    else
        ptOrgBtn = CPoint(rc.right - ScaleX(m_cyGripper) - 2, rc.top - ScaleY(m_cyGripper));

    m_biHide.Move(ptOrgBtn - rcBar.TopLeft());

    //MPC-BE custom code start
    // Work in screen coordinates before converting back to
    // client coordinates to account for possible RTL layout
    GetParent()->ScreenToClient(&rc);
    //MPC-BE custom code end

    *pRc = rc;
}

void CSizingControlBarG::NcPaintGripper(CDC* pDC, CRect rcClient)
{
    if (!HasGripper())
        return;

    if (!m_bUseDarkTheme) {
        // paints a simple "two raised lines" gripper
        // override this if you want a more sophisticated gripper
        CRect gripper = rcClient;
        CRect rcbtn = m_biHide.GetRect(CSize(ScaleX(m_cyGripper), ScaleY(m_cyGripper)));
        BOOL bHorz = IsHorzDocked();

        gripper.DeflateRect(1, 1);
        const auto sizeX = ScaleX(m_cyGripper) / 4;
        const auto sizeY = ScaleY(m_cyGripper) / 4;
        if (bHorz)
        {   // gripper at left
            gripper.left -= (ScaleX(m_cyGripper) / 2 + sizeX * 2);
            gripper.right = gripper.left + sizeX;
            gripper.top = rcbtn.bottom + 3;
        }
        else
        {   // gripper at top
            gripper.top -= (ScaleY(m_cyGripper) / 2 + sizeY * 2);
            gripper.bottom = gripper.top + sizeY;
            gripper.right = rcbtn.left - 3;
        }
        pDC->Draw3dRect(gripper, ::GetSysColor(COLOR_BTNHIGHLIGHT),
            ::GetSysColor(COLOR_BTNSHADOW));

        gripper.OffsetRect(bHorz ? sizeX : 0, bHorz ? 0 : sizeY);

        pDC->Draw3dRect(gripper, ::GetSysColor(COLOR_BTNHIGHLIGHT),
            ::GetSysColor(COLOR_BTNSHADOW));
    }

    m_biHide.Paint(pDC, this, CSize(ScaleX(m_cyGripper), ScaleY(m_cyGripper)));
}

LRESULT CSizingControlBarG::OnNcHitTest(CPoint point)
{
    CRect rcBar;
    GetWindowRect(rcBar);

    LRESULT nRet = baseCSizingControlBarG::OnNcHitTest(point);
    if (nRet != HTCLIENT)
        return nRet;

    //MPC-BE custom code start
    // Convert to client coordinates to account for possible RTL layout
    ScreenToClient(&rcBar);
    ScreenToClient(&point);
    //MPC-BE custom code end

    CRect rc = m_biHide.GetRect(CSize(ScaleX(m_cyGripper), ScaleY(m_cyGripper)));
    rc.OffsetRect(rcBar.TopLeft());
    if (rc.PtInRect(point))
        return HTCLOSE;

    return HTCLIENT;
}

/////////////////////////////////////////////////////////////////////////
// CSizingControlBarG implementation helpers

void CSizingControlBarG::OnUpdateCmdUI(CFrameWnd* pTarget,
                                      BOOL bDisableIfNoHndler)
{
    UNUSED_ALWAYS(bDisableIfNoHndler);
    UNUSED_ALWAYS(pTarget);

    if (!HasGripper())
        return;

    BOOL bNeedPaint = FALSE;

    CPoint pt;
    ::GetCursorPos(&pt);
    BOOL bHit = (OnNcHitTest(pt) == HTCLOSE);
    BOOL bLButtonDown = (::GetKeyState(VK_LBUTTON) < 0);

    BOOL bWasPushed = m_biHide.bPushed;
    m_biHide.bPushed = bHit && bLButtonDown;

    BOOL bWasRaised = m_biHide.bRaised;
    m_biHide.bRaised = bHit && !bLButtonDown;

    bNeedPaint |= (m_biHide.bPushed ^ bWasPushed) ||
                  (m_biHide.bRaised ^ bWasRaised);

    if (bNeedPaint)
        SendMessage(WM_NCPAINT);
}

/////////////////////////////////////////////////////////////////////////
// CSCBButton

CSCBButton::CSCBButton()
{
    bRaised = FALSE;
    bPushed = FALSE;
}

void CSCBButton::Paint(CDC* pDC, const CSizingControlBar* parent, const CSize& size/* = (DEFSIZE, DEFSIZE)*/)
{
    CRect rc = GetRect(size);

    // btn highlight
    if (bPushed)
        if (parent->m_bUseDarkTheme) {
            pDC->Draw3dRect(rc, parent->ColorThemeRGB(5, 10, 15), parent->ColorThemeRGB(55, 60, 65));
        } else {
            pDC->Draw3dRect(rc, ::GetSysColor(COLOR_BTNSHADOW),
                ::GetSysColor(COLOR_BTNHIGHLIGHT));
        }
    else if (bRaised)
        if (parent->m_bUseDarkTheme) {
            pDC->Draw3dRect(rc, parent->ColorThemeRGB(55, 60, 65), parent->ColorThemeRGB(5, 10, 15));
        } else {
            pDC->Draw3dRect(rc, ::GetSysColor(COLOR_BTNHIGHLIGHT),
                ::GetSysColor(COLOR_BTNSHADOW));
        }

    COLORREF clrOldTextColor = pDC->GetTextColor();
    pDC->SetTextColor(parent->m_bUseDarkTheme ? parent->ColorThemeRGB(125, 130, 135) : ::GetSysColor(COLOR_BTNTEXT));
    int nPrevBkMode = pDC->SetBkMode(TRANSPARENT);

    CFont font;
    font.CreateFontW(parent->ScaleY(9), 0, 0, 0, FW_SEMIBOLD, 0, 0, 0, DEFAULT_CHARSET,
                     OUT_RASTER_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, VARIABLE_PITCH | FF_MODERN, L"Marlett");

    CFont* oldfont = pDC->SelectObject(&font);

    //MPC-BE custom code start
    // TextOut is affected by the layout so we need to account for that
    DWORD dwLayout = pDC->GetLayout();
    pDC->TextOutW(ptOrg.x + (dwLayout == LAYOUT_LTR ? 2 : -1), ptOrg.y + 2, L"r"); // x-like
    //MPC-BE custom code end

    pDC->SelectObject(oldfont);
    pDC->SetBkMode(nPrevBkMode);
    pDC->SetTextColor(clrOldTextColor);
}

BOOL CSizingControlBarG::HasGripper() const
{
#if defined(_SCB_MINIFRAME_CAPTION) || !defined(_SCB_REPLACE_MINIFRAME)
    // if the miniframe has a caption, don't display the gripper
    if (IsFloating())
        return FALSE;
#endif //_SCB_MINIFRAME_CAPTION

    return TRUE;
}
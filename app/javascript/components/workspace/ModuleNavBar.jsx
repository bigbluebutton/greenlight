import React, { useMemo } from 'react';
import { Nav } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  FolderIcon,
  HomeIcon,
  PresentationChartLineIcon,
  RectangleStackIcon,
  Squares2X2Icon,
  VideoCameraIcon,
  WrenchScrewdriverIcon,
} from '@heroicons/react/24/outline';
import { useAuth } from '../../contexts/auth/AuthProvider';
import PermissionChecker from '../../helpers/PermissionChecker';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';

const MODULE_LABELS = {
  en: {
    home: 'Home',
    rooms: 'Rooms',
    sessions: 'Sessions',
    recordings: 'Recordings',
    files: 'Files',
    reports: 'Reports',
    admin: 'Admin',
  },
  tr: {
    home: 'Ana Sayfa',
    rooms: 'Odalar',
    sessions: 'Oturumlar',
    recordings: 'Kayitlar',
    files: 'Dosyalar',
    reports: 'Raporlar',
    admin: 'Yonetim',
  },
};

function moduleIsActive(pathname, key) {
  switch (key) {
    case 'home':
      return pathname === '/home';
    case 'rooms':
      return pathname === '/rooms' || pathname.startsWith('/rooms/');
    case 'sessions':
      return pathname === '/sessions';
    case 'recordings':
      return pathname === '/recordings';
    case 'files':
      return pathname === '/files';
    case 'reports':
      return pathname === '/reports';
    case 'admin':
      return pathname.startsWith('/admin');
    default:
      return false;
  }
}

export default function ModuleNavBar() {
  const currentUser = useAuth();
  const location = useLocation();
  const { i18n } = useTranslation();
  const { data: recordValue } = useRoomConfigValue('record');
  const language = (i18n.resolvedLanguage || i18n.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const labels = MODULE_LABELS[language];
  const canViewRecordings = recordValue !== 'false';
  const isAdmin = currentUser?.isSuperAdmin || PermissionChecker.isAdmin(currentUser);

  const modules = useMemo(() => {
    const list = [
      { key: 'home', label: labels.home, to: '/home', icon: HomeIcon },
      { key: 'rooms', label: labels.rooms, to: '/rooms', icon: Squares2X2Icon },
      { key: 'sessions', label: labels.sessions, to: '/sessions', icon: RectangleStackIcon },
    ];

    if (canViewRecordings) {
      list.push({ key: 'recordings', label: labels.recordings, to: '/recordings', icon: VideoCameraIcon });
    }

    list.push(
      { key: 'files', label: labels.files, to: '/files', icon: FolderIcon },
      { key: 'reports', label: labels.reports, to: '/reports', icon: PresentationChartLineIcon },
    );

    if (isAdmin) {
      list.push({ key: 'admin', label: labels.admin, to: '/admin', icon: WrenchScrewdriverIcon });
    }

    return list;
  }, [labels, canViewRecordings, isAdmin]);

  return (
    <div className="ak-module-nav-wrap">
      <div className="ak-module-nav-shell">
        <Nav className="ak-module-nav" as="nav" aria-label="Application Modules">
          {modules.map((item) => {
            const Icon = item.icon;
            return (
            <Nav.Link
              key={item.key}
              as={Link}
              to={item.to}
              className={`ak-module-nav-link ${moduleIsActive(location.pathname, item.key) ? 'is-active' : ''}`}
            >
              <Icon className="ak-module-nav-link-icon" aria-hidden="true" />
              {item.label}
            </Nav.Link>
            );
          })}
        </Nav>
      </div>
    </div>
  );
}

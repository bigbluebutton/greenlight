import React, { useMemo } from 'react';
import { Nav } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';
import PermissionChecker from '../../helpers/PermissionChecker';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';

const MODULE_LABELS = {
  en: {
    home: 'Home',
    rooms: 'Rooms',
    sessions: 'Sessions',
    recordings: 'Recordings',
    engagement: 'Engagement',
    files: 'Files',
    reports: 'Reports',
    admin: 'Admin',
  },
  tr: {
    home: 'Ana Sayfa',
    rooms: 'Odalar',
    sessions: 'Oturumlar',
    recordings: 'Kayitlar',
    engagement: 'Etkilesim',
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
    case 'engagement':
      return pathname === '/engagement';
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
      { key: 'home', label: labels.home, to: '/home' },
      { key: 'rooms', label: labels.rooms, to: '/rooms' },
      { key: 'sessions', label: labels.sessions, to: '/sessions' },
    ];

    if (canViewRecordings) {
      list.push({ key: 'recordings', label: labels.recordings, to: '/recordings' });
    }

    list.push(
      { key: 'engagement', label: labels.engagement, to: '/engagement' },
      { key: 'files', label: labels.files, to: '/files' },
      { key: 'reports', label: labels.reports, to: '/reports' },
    );

    if (isAdmin) {
      list.push({ key: 'admin', label: labels.admin, to: '/admin' });
    }

    return list;
  }, [labels, canViewRecordings, isAdmin]);

  return (
    <div className="ak-module-nav-wrap">
      <div className="ak-module-nav-shell">
        <Nav className="ak-module-nav" as="nav" aria-label="Application Modules">
          {modules.map((item) => (
            <Nav.Link
              key={item.key}
              as={Link}
              to={item.to}
              className={`ak-module-nav-link ${moduleIsActive(location.pathname, item.key) ? 'is-active' : ''}`}
            >
              {item.label}
            </Nav.Link>
          ))}
        </Nav>
      </div>
    </div>
  );
}

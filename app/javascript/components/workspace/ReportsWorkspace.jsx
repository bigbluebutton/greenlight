import React, {
  useEffect,
  useMemo,
  useState,
} from 'react';
import {
  CalendarDaysIcon,
  ChartBarIcon,
  VideoCameraIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';
import Rooms from '../rooms/Rooms';
import { getCurrentLanguage } from '../../helpers/LanguageHelper';

const REPORTS_MODULE_COPY = {
  en: {
    eyebrow: 'Reports',
    title: 'Reports and Analytics Hub',
    body: 'Analyze sessions, recordings, and learning evidence from one reporting workspace.',
    sessionsTab: 'Session Reports',
    recordingsTab: 'Recordings',
    analyticsTab: 'Analytics',
  },
  tr: {
    eyebrow: 'Raporlar',
    title: 'Rapor ve Analitik Merkezi',
    body: 'Oturumları, kayıtları ve öğrenme kanıtlarını tek raporlama alanından analiz edin.',
    sessionsTab: 'Oturum Raporları',
    recordingsTab: 'Kayıtlar',
    analyticsTab: 'Analitik',
  },
};

function ReportTab({
  active,
  icon: Icon,
  label,
  onClick,
}) {
  return (
    <button
      type="button"
      className={`ak-workspace-tab ${active ? 'is-active' : ''}`}
      onClick={onClick}
    >
      <Icon className="ak-workspace-tab-icon" aria-hidden="true" />
      <span>{label}</span>
    </button>
  );
}

export default function ReportsWorkspace() {
  const { i18n } = useTranslation();
  const currentUser = useAuth();
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');
  const copy = REPORTS_MODULE_COPY[language];
  const { data: recordValue } = useRoomConfigValue('record');
  const canViewRecordings = recordValue !== 'false';

  const tabs = useMemo(() => {
    const baseTabs = [
      { key: 'sessions', label: copy.sessionsTab, icon: CalendarDaysIcon },
      { key: 'analytics', label: copy.analyticsTab, icon: ChartBarIcon },
    ];

    if (canViewRecordings) {
      baseTabs.splice(1, 0, { key: 'recordings', label: copy.recordingsTab, icon: VideoCameraIcon });
    }

    return baseTabs;
  }, [canViewRecordings, copy.analyticsTab, copy.recordingsTab, copy.sessionsTab]);

  const [activeTab, setActiveTab] = useState('sessions');

  useEffect(() => {
    if (!tabs.some((tab) => tab.key === activeTab)) {
      setActiveTab(tabs[0]?.key || 'sessions');
    }
  }, [activeTab, tabs]);

  return (
    <div className="ak-workspace">
      <div className="ak-workspace-shell">
        <section className="ak-module-shell">
          <div className="ak-module-hero">
            <span className="ak-module-eyebrow">{copy.eyebrow}</span>
            <h1>{copy.title}</h1>
            <p>{copy.body}</p>
          </div>
        </section>

        <div className="ak-workspace-tabs ak-module-inline-tabs" role="tablist" aria-label={copy.title}>
          {tabs.map((tab) => (
            <ReportTab
              key={tab.key}
              active={activeTab === tab.key}
              icon={tab.icon}
              label={tab.label}
              onClick={() => setActiveTab(tab.key)}
            />
          ))}
        </div>

        <div className="ak-module-panel-stack">
          {activeTab === 'sessions' && <Rooms forcedView="schedule" hideTabs embedded />}
          {activeTab === 'recordings' && <Rooms forcedView="recordings" hideTabs embedded />}
          {activeTab === 'analytics' && <Rooms forcedView="analytics" hideTabs embedded />}
        </div>
      </div>
    </div>
  );
}

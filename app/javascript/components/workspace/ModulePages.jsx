import React from 'react';
import {
  CalendarDaysIcon,
  DocumentTextIcon,
  FolderIcon,
  PresentationChartLineIcon,
  RectangleStackIcon,
  Squares2X2Icon,
} from '@heroicons/react/24/outline';
import Rooms from '../rooms/Rooms';

function ModuleCard({
  title, body, href, icon: Icon,
}) {
  const content = (
    <>
      <span className="ak-module-card-icon">
        <Icon aria-hidden="true" />
      </span>
      <div className="ak-module-card-copy">
        <strong>{title}</strong>
        {body && <span>{body}</span>}
      </div>
    </>
  );

  if (href) {
    return (
      <a className="ak-module-card" href={href}>
        {content}
      </a>
    );
  }

  return <div className="ak-module-card">{content}</div>;
}

function ModuleShell({ eyebrow, title, body, cards }) {
  return (
    <div className="ak-workspace">
      <div className="ak-workspace-shell">
        <section className="ak-module-shell">
          <div className="ak-module-hero">
            <span className="ak-module-eyebrow">{eyebrow}</span>
            <h1>{title}</h1>
            <p>{body}</p>
          </div>
          <div className="ak-module-card-grid">
            {cards.map((card) => (
              <ModuleCard key={card.title} {...card} />
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

export function DashboardModule() {
  return <Rooms forcedView="overview" hideTabs />;
}

export function RoomsModule() {
  return <Rooms forcedView="rooms" hideTabs />;
}

export function SessionsModule() {
  return <Rooms forcedView="schedule" hideTabs />;
}

export function RecordingsModule() {
  return <Rooms forcedView="recordings" hideTabs />;
}

export function AdminModule() {
  return <Rooms forcedView="admin" hideTabs />;
}

export function FilesModule() {
  return (
    <ModuleShell
      eyebrow="Files"
      title="Session and Room Files"
      body="This module is the next native migration target. Start with a structured file layer for rooms, sessions, and shared assets."
      cards={[
        {
          title: 'My Files',
          body: 'Private working files and uploads.',
          icon: FolderIcon,
        },
        {
          title: 'Shared Files',
          body: 'Assets shared across teams and cohorts.',
          icon: RectangleStackIcon,
        },
        {
          title: 'Session Attachments',
          body: 'Pre-session and post-session materials.',
          icon: DocumentTextIcon,
        },
        {
          title: 'Room Templates',
          body: 'Reusable room-level materials and defaults.',
          icon: Squares2X2Icon,
        },
      ]}
    />
  );
}

export function ReportsModule() {
  return (
    <ModuleShell
      eyebrow="Reports"
      title="Reports and Analytics Hub"
      body="Historical evidence, exports, recordings, and learning analytics move here as the next reporting layer."
      cards={[
        {
          title: 'Recording Evidence',
          body: 'Review recordings, past sessions, and per-user evidence.',
          href: '/recordings',
          icon: PresentationChartLineIcon,
        },
        {
          title: 'Learning Analytics',
          body: 'Open the native BBB analytics experience.',
          href: '/learning-analytics-dashboard/',
          icon: CalendarDaysIcon,
        },
        {
          title: 'Attendance CSV',
          body: 'Export attendance evidence in CSV format.',
          href: '/ext/export/attendance.csv',
          icon: DocumentTextIcon,
        },
      ]}
    />
  );
}

import React from 'react';
import Rooms from '../rooms/Rooms';
import FilesWorkspace from './FilesWorkspace';
import ReportsWorkspace from './ReportsWorkspace';

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
  return <FilesWorkspace />;
}

export function ReportsModule() {
  return <ReportsWorkspace />;
}

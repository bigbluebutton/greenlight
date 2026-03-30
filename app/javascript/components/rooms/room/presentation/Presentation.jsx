// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useMemo, useRef } from 'react';
import {
  Button, Card, Stack, Table,
} from 'react-bootstrap';
import {
  ArrowTopRightOnSquareIcon,
  CloudArrowUpIcon,
  FolderIcon,
} from '@heroicons/react/24/outline';
import { useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import useUploadPresentation from '../../../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import useRoomPresentationLibrary from '../../../../hooks/queries/rooms/useRoomPresentationLibrary';
import useGlobalPresentationTemplates from '../../../../hooks/queries/rooms/useGlobalPresentationTemplates';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import axios from '../../../../helpers/Axios';
import Modal from '../../../shared_components/modals/Modal';
import DeletePresentationForm from './forms/DeletePresentationForm';
import { PRESENTATION_SUPPORTED_EXTENSIONS } from '../../../../helpers/FileValidationHelper';
import { getCurrentLanguage } from '../../../../helpers/LanguageHelper';

const FILE_LIBRARY_COPY = {
  en: {
    currentDefault: 'Current default presentation',
    noDefault: 'No default presentation selected yet.',
    upload: 'Upload File',
    viewCurrent: 'View current file',
    removeCurrent: 'Remove default',
    myFiles: 'My Files',
    sharedFiles: 'Shared Folder',
    fileName: 'File Name',
    owner: 'Creator / Owner',
    creationDate: 'Creation Date',
    type: 'Type',
    size: 'Size',
    actions: 'Actions',
    room: 'Room',
    currentRoom: 'Current Room',
    setDefault: 'Set as Default',
    view: 'View',
    delete: 'Delete',
    loading: 'Loading files...',
    emptyFolder: 'No files in this folder yet.',
    templateUpdated: 'Default presentation updated.',
    templateUpdateError: 'Unable to use this file as the default presentation.',
    fileDeleted: 'File removed from your library.',
    fileDeleteError: 'Unable to remove this file.',
  },
  tr: {
    currentDefault: 'Mevcut varsayılan sunum',
    noDefault: 'Henüz varsayılan bir sunum seçilmedi.',
    upload: 'Dosya Yükle',
    viewCurrent: 'Mevcut dosyayı aç',
    removeCurrent: 'Varsayılanı kaldır',
    myFiles: 'Dosyalarım',
    sharedFiles: 'Paylaşılan Klasör',
    fileName: 'Dosya Adı',
    owner: 'Oluşturan / Sahip',
    creationDate: 'Oluşturma Tarihi',
    type: 'Tür',
    size: 'Boyut',
    actions: 'İşlemler',
    room: 'Oda',
    currentRoom: 'Bu Oda',
    setDefault: 'Varsayılan Yap',
    view: 'Görüntüle',
    delete: 'Sil',
    loading: 'Dosyalar yükleniyor...',
    emptyFolder: 'Bu klasörde henüz dosya yok.',
    templateUpdated: 'Varsayılan sunum güncellendi.',
    templateUpdateError: 'Bu dosya varsayılan sunum olarak ayarlanamadı.',
    fileDeleted: 'Dosya kütüphanenizden kaldırıldı.',
    fileDeleteError: 'Bu dosya kaldırılamadı.',
  },
};

function formatDate(value, language) {
  if (!value) return '-';

  try {
    return new Intl.DateTimeFormat(
      language === 'tr' ? 'tr-TR' : 'en-US',
      { dateStyle: 'medium', timeStyle: 'short' },
    ).format(new Date(value));
  } catch (_) {
    return value;
  }
}

function formatSize(value) {
  const size = Number(value);
  if (!Number.isFinite(size) || size <= 0) return '-';

  if (size < 1024) return `${size} B`;
  if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`;
  if (size < 1024 * 1024 * 1024) return `${(size / (1024 * 1024)).toFixed(1)} MB`;
  return `${(size / (1024 * 1024 * 1024)).toFixed(1)} GB`;
}

function formatType(fileName, contentType) {
  const extension = fileName?.split('.').pop();
  if (extension && extension !== fileName) {
    return extension.toUpperCase();
  }

  if (contentType) return contentType;

  return '-';
}

function extractErrorMessage(error, fallback) {
  const apiErrors = error?.response?.data?.errors;
  if (Array.isArray(apiErrors) && apiErrors.length) return apiErrors[0];
  if (error instanceof Error && error.message) return error.message;
  return fallback;
}

function FolderTable({
  title,
  files,
  friendlyId,
  isLoading,
  isApplying,
  isDeleting,
  onUseAsDefault,
  onDeleteFile,
  copy,
  language,
}) {
  return (
    <Card className="border-0 card-shadow mt-3 ak-room-files-card">
      <Card.Header className="bg-white border-0 py-3 ak-room-files-header">
        <Stack direction="horizontal" gap={2} className="text-brand fw-semibold">
          <FolderIcon className="hi-s" />
          <span>{title}</span>
        </Stack>
        <span className="ak-room-files-count">{files.length}</span>
      </Card.Header>
      <Card.Body className="p-0">
        <Table responsive hover className="text-secondary mb-0 ak-room-files-table">
          <thead>
            <tr className="text-muted small">
              <th className="fw-normal">{copy.fileName}</th>
              <th className="fw-normal">{copy.owner}</th>
              <th className="fw-normal">{copy.creationDate}</th>
              <th className="fw-normal">{copy.type}</th>
              <th className="fw-normal">{copy.size}</th>
              <th className="fw-normal text-end">{copy.actions}</th>
            </tr>
          </thead>
          <tbody className="border-top-0">
            {isLoading && (
              <tr>
                <td colSpan="6" className="py-4 text-center">{copy.loading}</td>
              </tr>
            )}
            {!isLoading && !files.length && (
              <tr>
                <td colSpan="6" className="py-4 text-center">{copy.emptyFolder}</td>
              </tr>
            )}
            {!isLoading && files.map((file) => (
              <tr key={file.sourceFriendlyId || `global-${file.globalTemplateKey}`} className="align-middle">
                <td>
                  <div className="fw-semibold text-dark">{file.name}</div>
                  <div className="small text-muted">
                    <span className="ak-room-files-pill">{file.roomName}</span>
                  </div>
                </td>
                <td>{file.owner}</td>
                <td>{formatDate(file.createdAt, language)}</td>
                <td>{formatType(file.name, file.contentType)}</td>
                <td>{formatSize(file.byteSize)}</td>
                <td>
                  <Stack direction="horizontal" gap={2} className="justify-content-end flex-wrap py-2">
                    {file.url && (
                      <a
                        href={file.url}
                        target="_blank"
                        rel="noreferrer"
                        className="btn btn-sm btn-outline-secondary"
                      >
                        <ArrowTopRightOnSquareIcon className="hi-s me-1" />
                        {copy.view}
                      </a>
                    )}
                    {file.canDelete && (
                      <Button
                        size="sm"
                        variant="outline-danger"
                        disabled={isDeleting || isApplying}
                        onClick={() => onDeleteFile(file)}
                      >
                        {copy.delete}
                      </Button>
                    )}
                    <Button
                      size="sm"
                      variant={file.sourceFriendlyId === friendlyId ? 'outline-secondary' : 'brand-outline'}
                      disabled={(file.sourceFriendlyId === friendlyId && !file.globalTemplateKey) || isApplying}
                      onClick={() => onUseAsDefault(file)}
                    >
                      {(file.sourceFriendlyId === friendlyId && !file.globalTemplateKey) ? copy.currentRoom : copy.setDefault}
                    </Button>
                  </Stack>
                </td>
              </tr>
            ))}
          </tbody>
        </Table>
      </Card.Body>
    </Card>
  );
}

export default function Presentation({ friendlyId: friendlyIdProp = '' }) {
  const { i18n } = useTranslation();
  const { friendlyId: routeFriendlyId } = useParams();
  const friendlyId = friendlyIdProp || routeFriendlyId;
  const { data: room } = useRoom(friendlyId);
  const { data: accessibleRooms, isLoading: roomsLoading } = useRoomPresentationLibrary(friendlyId);
  const { data: globalTemplates = [], isLoading: globalTemplatesLoading } = useGlobalPresentationTemplates();
  const currentUser = useAuth();
  const queryClient = useQueryClient();
  const fileInputRef = useRef(null);
  const uploadPresentation = useUploadPresentation(friendlyId);
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');
  const copy = FILE_LIBRARY_COPY[language];

  const applyTemplate = useMutation(
    (file) => {
      if (file?.globalTemplateKey) {
        return axios.post(`/rooms/${friendlyId}/use_global_presentation_template.json`, {
          global_source_key: file.globalTemplateKey,
        });
      }

      return axios.post(`/rooms/${friendlyId}/use_presentation_template.json`, {
        source_friendly_id: file?.sourceFriendlyId,
      });
    },
    {
      onSuccess: async () => {
        await queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        await queryClient.invalidateQueries(['getRoomPresentationLibrary', { friendlyId }]);
        await queryClient.invalidateQueries(['getUserPresentationLibrary']);
        await queryClient.invalidateQueries(['getGlobalPresentationTemplates']);
        await queryClient.invalidateQueries(['getRooms']);
        toast.success(copy.templateUpdated);
      },
      onError: (error) => {
        toast.error(extractErrorMessage(error, copy.templateUpdateError));
      },
    },
  );

  const deleteLibraryFile = useMutation(
    (sourceFriendlyId) => axios.delete(`/rooms/${sourceFriendlyId}/purge_presentation.json`),
    {
      onSuccess: async () => {
        await queryClient.invalidateQueries(['getRoom', { friendlyId }]);
        await queryClient.invalidateQueries(['getRoomPresentationLibrary', { friendlyId }]);
        await queryClient.invalidateQueries(['getUserPresentationLibrary']);
        await queryClient.invalidateQueries(['getGlobalPresentationTemplates']);
        await queryClient.invalidateQueries(['getRooms']);
        toast.success(copy.fileDeleted);
      },
      onError: (error) => {
        toast.error(extractErrorMessage(error, copy.fileDeleteError));
      },
    },
  );

  const fileEntries = useMemo(() => {
    const sourceRooms = [];
    const seenRooms = new Set();

    (Array.isArray(accessibleRooms) ? accessibleRooms : []).forEach((sourceRoom) => {
      if (!sourceRoom?.friendly_id || seenRooms.has(sourceRoom.friendly_id)) return;
      seenRooms.add(sourceRoom.friendly_id);
      sourceRooms.push(sourceRoom);
    });

    if (room?.presentation_name && !seenRooms.has(friendlyId)) {
      sourceRooms.push({
        friendly_id: friendlyId,
        name: room?.name,
        presentation_name: room?.presentation_name,
        presentation_url: room?.presentation_url,
        presentation_content_type: room?.presentation_content_type,
        presentation_byte_size: room?.presentation_byte_size,
        presentation_created_at: room?.presentation_created_at,
        shared_owner: null,
      });
    }

    return sourceRooms
      .filter((sourceRoom) => sourceRoom?.presentation_name)
      .map((sourceRoom) => ({
        sourceFriendlyId: sourceRoom.friendly_id,
        globalTemplateKey: '',
        roomName: sourceRoom.name || friendlyId,
        name: sourceRoom.presentation_name,
        owner: sourceRoom.shared_owner || room?.owner_name || currentUser?.name || '-',
        createdAt: sourceRoom.presentation_created_at,
        contentType: sourceRoom.presentation_content_type,
        byteSize: sourceRoom.presentation_byte_size,
        url: sourceRoom.presentation_url,
        folder: sourceRoom.shared_owner ? 'shared' : 'owned',
        canDelete: !sourceRoom.shared_owner && !room?.shared,
      }));
  }, [accessibleRooms, currentUser?.name, friendlyId, room]);

  const globalTemplateEntries = useMemo(
    () => normalizeGlobalTemplates(globalTemplates),
    [globalTemplates],
  );

  const myFiles = useMemo(
    () => fileEntries.filter((file) => file.folder === 'owned'),
    [fileEntries],
  );
  const sharedFiles = useMemo(
    () => [
      ...fileEntries.filter((file) => file.folder === 'shared'),
      ...globalTemplateEntries,
    ],
    [fileEntries, globalTemplateEntries],
  );

  const handleFileUpload = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      await uploadPresentation.mutateAsync(file);
    } catch (_) {
      // Mutation hook already reports upload failures.
    } finally {
      event.target.value = '';
    }
  };

  return (
    <div className="pt-3 ak-room-files">
      <Card className="border-0 card-shadow ak-room-files-card ak-room-files-current">
        <Card.Body className="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
          <div>
            <div className="text-muted text-uppercase small fw-semibold">{copy.currentDefault}</div>
            <div className="fs-5 fw-semibold text-brand mt-1">
              {room?.presentation_name || copy.noDefault}
            </div>
            <div className="ak-room-files-current-meta">
              {room?.name && <span className="ak-room-files-pill">{room.name}</span>}
              {room?.presentation_created_at && <span>{formatDate(room.presentation_created_at, language)}</span>}
            </div>
          </div>
          <Stack direction="horizontal" gap={2} className="flex-wrap">
            {room?.presentation_url && (
              <a
                href={room.presentation_url}
                target="_blank"
                rel="noreferrer"
                className="btn btn-outline-secondary"
              >
                <ArrowTopRightOnSquareIcon className="hi-s me-1" />
                {copy.viewCurrent}
              </a>
            )}
            {room?.presentation_name && (
              <Modal
                modalButton={<Button variant="outline-danger">{copy.removeCurrent}</Button>}
                title={copy.removeCurrent}
                body={<DeletePresentationForm />}
              />
            )}
            <Button
              variant="brand-outline"
              onClick={() => fileInputRef.current?.click()}
              disabled={uploadPresentation.isLoading}
            >
              <CloudArrowUpIcon className="hi-s me-1" />
              {copy.upload}
            </Button>
            <input
              ref={fileInputRef}
              className="d-none"
              type="file"
              accept={PRESENTATION_SUPPORTED_EXTENSIONS.join(',')}
              onChange={handleFileUpload}
            />
          </Stack>
        </Card.Body>
      </Card>

      <FolderTable
        title={copy.myFiles}
        files={myFiles}
        friendlyId={friendlyId}
        isLoading={roomsLoading || globalTemplatesLoading}
        isApplying={applyTemplate.isLoading}
        isDeleting={deleteLibraryFile.isLoading}
        onUseAsDefault={(file) => applyTemplate.mutate(file)}
        onDeleteFile={(file) => {
          if (!file?.canDelete || !file?.sourceFriendlyId) return;
          deleteLibraryFile.mutate(file.sourceFriendlyId);
        }}
        copy={copy}
        language={language}
      />

      <FolderTable
        title={copy.sharedFiles}
        files={sharedFiles}
        friendlyId={friendlyId}
        isLoading={roomsLoading || globalTemplatesLoading}
        isApplying={applyTemplate.isLoading}
        isDeleting={deleteLibraryFile.isLoading}
        onUseAsDefault={(file) => applyTemplate.mutate(file)}
        onDeleteFile={() => {}}
        copy={copy}
        language={language}
      />
    </div>
  );
}

function normalizeGlobalTemplates(templates) {
  if (!Array.isArray(templates)) return [];

  return templates
    .filter((template) => template?.key && template?.name)
    .map((template) => ({
      sourceFriendlyId: '',
      globalTemplateKey: template.key,
      roomName: template.room_name || 'Akademio Library',
      name: template.name,
      owner: template.shared_owner || 'Akademio Live',
      createdAt: template.created_at,
      contentType: template.content_type,
      byteSize: template.byte_size,
      url: template.url,
      folder: 'shared',
      canDelete: false,
    }));
}

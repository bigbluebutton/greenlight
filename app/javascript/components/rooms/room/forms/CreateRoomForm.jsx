import React, { useEffect, useMemo, useState } from 'react';
import {
  Button, Form as BootstrapForm, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomForm from '../../../../hooks/forms/rooms/useRoomForm';
import useUserPresentationLibrary from '../../../../hooks/queries/rooms/useUserPresentationLibrary';
import useGlobalPresentationTemplates from '../../../../hooks/queries/rooms/useGlobalPresentationTemplates';
import { ROOM_ICON_OPTIONS, getRoomIconOption } from '../../../../helpers/RoomVisuals';
import { IMAGE_SUPPORTED_EXTENSIONS, PRESENTATION_SUPPORTED_EXTENSIONS } from '../../../../helpers/FileValidationHelper';
import { getCurrentLanguage } from '../../../../helpers/LanguageHelper';

function SettingToggle({
  checked, description, disabled, onChange,
}) {
  return (
    <label className={`ak-create-room-setting-row ${disabled ? 'is-disabled' : ''}`}>
      <span>{description}</span>
      <span className="ak-create-room-setting-switch">
        <input
          type="checkbox"
          checked={checked}
          onChange={(event) => onChange(event.target.checked)}
          disabled={disabled}
        />
        <span className="ak-create-room-setting-slider" />
      </span>
    </label>
  );
}

SettingToggle.propTypes = {
  checked: PropTypes.bool.isRequired,
  description: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  onChange: PropTypes.func.isRequired,
};

SettingToggle.defaultProps = {
  disabled: false,
};

export default function CreateRoomForm({ mutation: useCreateRoomAPI, userId, handleClose }) {
  const { t, i18n } = useTranslation();
  const currentUser = useAuth();
  const createRoomAPI = useCreateRoomAPI({ onSettled: handleClose });
  const { methods, fields } = useRoomForm({ defaultValues: { user_id: userId } });
  const [activePanel, setActivePanel] = useState('basics');
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');
  const canRecord = currentUser?.permissions?.CanRecord === 'true';
  const selectedIconKey = methods.watch('icon_key') || 'general';
  const selectedDestination = methods.watch('post_create_tab') || 'default';
  const selectedIcon = getRoomIconOption(selectedIconKey);
  const selectedPresentation = methods.watch('presentation');
  const selectedLibraryFriendlyId = methods.watch('presentation_source_friendly_id') || '';
  const selectedGlobalTemplateKey = methods.watch('presentation_global_source_key') || '';
  const selectedThumbnail = methods.watch('thumbnail_image');
  const joinAsModerator = !!methods.watch('glAnyoneJoinAsModerator');
  const { data: presentationLibrary = [], isLoading: libraryLoading } = useUserPresentationLibrary(userId);
  const { data: globalTemplates = [], isLoading: globalTemplatesLoading } = useGlobalPresentationTemplates();
  const previewThumbnailUrl = useMemo(
    () => (selectedThumbnail ? URL.createObjectURL(selectedThumbnail) : ''),
    [selectedThumbnail],
  );

  const copy = useMemo(() => (
    language === 'tr'
      ? {
        tabs: {
          basics: 'Temeller',
          settings: 'Ayarlar',
          files: 'Dosyalar',
        },
        iconLabel: 'Oda ikonu',
        iconHelp: 'Oda listesinde ve detay sayfasında görünecek görsel türünü seçin.',
        thumbnailLabel: 'Oda görseli yükle',
        thumbnailHelp: 'İsterseniz seçilen ikon yerine kullanılacak bir görsel yükleyin.',
        noThumbnail: 'Özel görsel seçilmedi',
        userSettings: 'Kullanıcı ayarları',
        record: 'Oda kaydına izin ver',
        requireAuth: 'Katılım için oturum açmayı zorunlu kıl',
        requireApproval: 'Katılım öncesi moderatör onayı iste',
        anyoneCanStart: 'Herhangi bir kullanıcı oturumu başlatabilsin',
        allMods: 'Tüm kullanıcılar moderatör olarak katılsın',
        muteOnStart: 'Katılımcılar girişte sessize alınsın',
        settingsHint: 'Bu ayarlar oda oluşturulduktan hemen sonra uygulanır.',
        settingsTitle: 'Oluşturma sonrası hedef',
        settingsNow: 'Oluştur ve Ayarları aç',
        settingsLater: 'Oluştur ve Odalar listesine dön',
        filesTitle: 'Sunum ve oda dosyaları',
        filesBody: 'Yeni bir sunum yükleyin veya kullanıcının mevcut dosya kütüphanesinden seçin.',
        uploadLabel: 'Yeni sunum yükle',
        uploadHelp: 'Desteklenen formatlar: DOC, PPT, PDF, XLS, TXT, ODT, ODS, ODP, JPG, PNG.',
        selectedFile: 'Seçili dosya',
        noFile: 'Sunum seçilmedi',
        libraryLabel: 'Mevcut dosyalar',
        myFiles: 'Dosyalarım',
        sharedFiles: 'Paylaşılan Klasör',
        selectLibrary: 'Dosya seçin',
        loadingLibrary: 'Dosyalar yükleniyor...',
        noLibrary: 'Kullanılabilir dosya bulunamadı',
        selectedLibrary: 'Seçili kütüphane dosyası',
        noLibrarySelected: 'Kütüphane dosyası seçilmedi',
        filesNow: 'Oluştur ve Dosyaları aç',
        filesLater: 'Oluştur ve Oda Detayını aç',
        previewTitle: 'Seçili görünüm',
        previewBody: 'Seçilen ikon ve varsa özel görsel oda ile birlikte kaydedilir. Oda oluştuktan sonra değiştirebilirsiniz.',
      }
      : {
        tabs: {
          basics: 'Basics',
          settings: 'Settings',
          files: 'Files',
        },
        iconLabel: 'Room icon',
        iconHelp: 'Choose the visual type shown in the room list and room detail header.',
        thumbnailLabel: 'Upload room thumbnail',
        thumbnailHelp: 'Optional image that overrides the icon across all devices and users.',
        noThumbnail: 'No custom thumbnail selected',
        userSettings: 'User settings',
        record: 'Allow room to be recorded',
        requireAuth: 'Require users to be signed in before joining',
        requireApproval: 'Require moderator approval before joining',
        anyoneCanStart: 'Allow any user to start this meeting',
        allMods: 'All users join as moderators',
        muteOnStart: 'Mute users when they join',
        settingsHint: 'These settings are applied immediately after the room is created.',
        settingsTitle: 'After-create destination',
        settingsNow: 'Create and open Settings',
        settingsLater: 'Create and return to Rooms',
        filesTitle: 'Presentation and room files',
        filesBody: 'Upload a new presentation now or choose one from the user file library.',
        uploadLabel: 'Upload new presentation',
        uploadHelp: 'Supported formats: DOC, PPT, PDF, XLS, TXT, ODT, ODS, ODP, JPG, PNG.',
        selectedFile: 'Selected file',
        noFile: 'No presentation selected',
        libraryLabel: 'Available files',
        myFiles: 'My Files',
        sharedFiles: 'Shared Folder',
        selectLibrary: 'Select a file',
        loadingLibrary: 'Loading files...',
        noLibrary: 'No reusable files available',
        selectedLibrary: 'Selected library file',
        noLibrarySelected: 'No library file selected',
        defaultFiles: 'Default Files',
        filesNow: 'Create and open Files',
        filesLater: 'Create and open Room Detail',
        previewTitle: 'Selected visual',
        previewBody: 'The icon and optional thumbnail are saved with the room and can be changed later from the room header.',
      }
  ), [language]);

  const libraryFiles = useMemo(
    () => (Array.isArray(presentationLibrary) ? presentationLibrary.filter((room) => room?.presentation_name) : []),
    [presentationLibrary],
  );
  const myFiles = useMemo(
    () => libraryFiles.filter((room) => !room.shared_owner),
    [libraryFiles],
  );
  const sharedFiles = useMemo(
    () => libraryFiles.filter((room) => !!room.shared_owner),
    [libraryFiles],
  );
  const selectedLibraryFile = useMemo(
    () => libraryFiles.find((room) => room.friendly_id === selectedLibraryFriendlyId) || null,
    [libraryFiles, selectedLibraryFriendlyId],
  );
  const availableGlobalTemplates = useMemo(
    () => (Array.isArray(globalTemplates) ? globalTemplates.filter((template) => template?.key && template?.name) : []),
    [globalTemplates],
  );
  const selectedGlobalTemplate = useMemo(
    () => availableGlobalTemplates.find((template) => template.key === selectedGlobalTemplateKey) || null,
    [availableGlobalTemplates, selectedGlobalTemplateKey],
  );
  const selectedLibraryOptionValue = selectedGlobalTemplateKey ? `global:${selectedGlobalTemplateKey}` : (
    selectedLibraryFriendlyId ? `room:${selectedLibraryFriendlyId}` : ''
  );

  const settingItems = useMemo(() => {
    const items = [
      {
        key: 'glRequireAuthentication',
        label: copy.requireAuth,
      },
      {
        key: 'guestPolicy',
        label: copy.requireApproval,
        disabled: joinAsModerator,
      },
      {
        key: 'glAnyoneCanStart',
        label: copy.anyoneCanStart,
      },
      {
        key: 'glAnyoneJoinAsModerator',
        label: copy.allMods,
      },
      {
        key: 'muteOnStart',
        label: copy.muteOnStart,
      },
    ];

    if (canRecord) {
      items.unshift({
        key: 'record',
        label: copy.record,
      });
    }

    return items;
  }, [canRecord, copy, joinAsModerator]);

  const selectPanel = (panel) => {
    setActivePanel(panel);

    if (panel === 'settings' && selectedDestination === 'default') {
      methods.setValue('post_create_tab', 'settings', { shouldDirty: true });
    }

    if (panel === 'files' && (selectedDestination === 'default' || selectedDestination === 'settings')) {
      methods.setValue('post_create_tab', 'files', { shouldDirty: true });
    }
  };

  const onPresentationChange = (event) => {
    const file = event.target.files?.[0] || null;
    methods.setValue('presentation', file, { shouldDirty: true });
    if (file) {
      methods.setValue('presentation_source_friendly_id', '', { shouldDirty: true });
      methods.setValue('presentation_global_source_key', '', { shouldDirty: true });
    }
  };

  const onThumbnailChange = (event) => {
    const file = event.target.files?.[0] || null;
    methods.setValue('thumbnail_image', file, { shouldDirty: true });
  };

  useEffect(() => {
    [
      'record',
      'glRequireAuthentication',
      'guestPolicy',
      'glAnyoneCanStart',
      'glAnyoneJoinAsModerator',
      'muteOnStart',
      'presentation',
      'presentation_source_friendly_id',
      'presentation_global_source_key',
      'thumbnail_image',
    ].forEach((field) => methods.register(field));
  }, [methods]);

  useEffect(() => {
    if (selectedLibraryFriendlyId && !libraryFiles.some((room) => room.friendly_id === selectedLibraryFriendlyId)) {
      methods.setValue('presentation_source_friendly_id', '', { shouldDirty: true });
    }
  }, [libraryFiles, methods, selectedLibraryFriendlyId]);

  useEffect(() => {
    if (selectedGlobalTemplateKey && !availableGlobalTemplates.some((template) => template.key === selectedGlobalTemplateKey)) {
      methods.setValue('presentation_global_source_key', '', { shouldDirty: true });
    }
  }, [availableGlobalTemplates, methods, selectedGlobalTemplateKey]);

  const formatLibraryOptionLabel = (room) => {
    const ownerSuffix = room.shared_owner ? ` (${room.shared_owner})` : '';
    return `${room.presentation_name} - ${room.name}${ownerSuffix}`;
  };

  useEffect(() => () => {
    if (previewThumbnailUrl) URL.revokeObjectURL(previewThumbnailUrl);
  }, [previewThumbnailUrl]);

  return (
    <Form methods={methods} onSubmit={createRoomAPI.mutate} className="ak-create-room-form">
      <input type="hidden" {...methods.register('icon_key')} />
      <input type="hidden" {...methods.register('post_create_tab')} />

      <div className="ak-create-room-tabs" role="tablist" aria-label="Create room workflow">
        {Object.entries(copy.tabs).map(([key, label]) => (
          <button
            key={key}
            type="button"
            className={`ak-create-room-tab ${activePanel === key ? 'is-active' : ''}`}
            onClick={() => selectPanel(key)}
          >
            {label}
          </button>
        ))}
      </div>

      <div className="ak-create-room-shell">
        <div className="ak-create-room-main">
          {activePanel === 'basics' && (
            <>
              <FormControl field={fields.name} type="text" autoFocus />
              <div className="ak-create-room-section">
                <span className="ak-create-room-label">{copy.iconLabel}</span>
                <p className="ak-create-room-help">{copy.iconHelp}</p>
                <div className="ak-create-room-icon-grid">
                  {ROOM_ICON_OPTIONS.map((item) => (
                    <button
                      key={item.key}
                      type="button"
                      className={`ak-create-room-icon-option ${selectedIconKey === item.key ? 'is-active' : ''}`}
                      onClick={() => methods.setValue('icon_key', item.key, { shouldDirty: true })}
                    >
                      <span className="ak-create-room-icon-emoji" aria-hidden="true">{item.emoji}</span>
                      <span className="ak-create-room-icon-label">{item.label}</span>
                    </button>
                  ))}
                </div>
                <div className="ak-create-room-upload-box mt-3">
                  <label className="ak-create-room-upload-label" htmlFor="create-room-thumbnail">
                    {copy.thumbnailLabel}
                  </label>
                  <input
                    id="create-room-thumbnail"
                    type="file"
                    className="ak-create-room-upload-input"
                    accept={IMAGE_SUPPORTED_EXTENSIONS.join(',')}
                    onChange={onThumbnailChange}
                  />
                  <small>{copy.thumbnailHelp}</small>
                  <div className="ak-create-room-file-meta">
                    <span>{copy.thumbnailLabel}</span>
                    <strong>{selectedThumbnail?.name || copy.noThumbnail}</strong>
                  </div>
                </div>
              </div>
            </>
          )}

          {activePanel === 'settings' && (
            <div className="ak-create-room-section">
              <span className="ak-create-room-label">{copy.userSettings}</span>
              <p className="ak-create-room-help">{copy.settingsHint}</p>
              <div className="ak-create-room-settings-list">
                {settingItems.map((item) => (
                  <SettingToggle
                    key={item.key}
                    checked={!!methods.watch(item.key)}
                    description={item.label}
                    disabled={item.disabled}
                    onChange={(value) => {
                      methods.setValue(item.key, value, { shouldDirty: true });
                      if (item.key === 'glAnyoneJoinAsModerator' && value) {
                        methods.setValue('guestPolicy', false, { shouldDirty: true });
                      }
                    }}
                  />
                ))}
              </div>

              <div className="ak-create-room-section ak-create-room-section-spaced">
                <span className="ak-create-room-label">{copy.settingsTitle}</span>
                <div className="ak-create-room-choice-grid">
                  <button
                    type="button"
                    className={`ak-create-room-choice ${selectedDestination === 'settings' ? 'is-active' : ''}`}
                    onClick={() => methods.setValue('post_create_tab', 'settings', { shouldDirty: true })}
                  >
                    {copy.settingsNow}
                  </button>
                  <button
                    type="button"
                    className={`ak-create-room-choice ${selectedDestination === 'list' ? 'is-active' : ''}`}
                    onClick={() => methods.setValue('post_create_tab', 'list', { shouldDirty: true })}
                  >
                    {copy.settingsLater}
                  </button>
                </div>
              </div>
            </div>
          )}

          {activePanel === 'files' && (
            <div className="ak-create-room-section">
              <span className="ak-create-room-label">{copy.filesTitle}</span>
              <p className="ak-create-room-help">{copy.filesBody}</p>

              <div className="ak-create-room-upload-box">
                <label className="ak-create-room-upload-label" htmlFor="create-room-presentation">
                  {copy.uploadLabel}
                </label>
                <input
                  id="create-room-presentation"
                  type="file"
                  className="ak-create-room-upload-input"
                  accept={PRESENTATION_SUPPORTED_EXTENSIONS.join(',')}
                  onChange={onPresentationChange}
                />
                <small>{copy.uploadHelp}</small>
                <div className="ak-create-room-file-meta">
                  <span>{copy.selectedFile}</span>
                  <strong>{selectedPresentation?.name || copy.noFile}</strong>
                </div>
              </div>

              <div className="ak-create-room-library-box">
                <label className="ak-create-room-upload-label" htmlFor="create-room-file-library">
                  {copy.libraryLabel}
                </label>
                <select
                  id="create-room-file-library"
                  className="ak-create-room-select"
                  value={selectedLibraryOptionValue}
                  disabled={(libraryLoading || globalTemplatesLoading) && !(libraryFiles.length || availableGlobalTemplates.length)}
                  onChange={(event) => {
                    const nextValue = event.target.value;
                    if (!nextValue) {
                      methods.setValue('presentation_source_friendly_id', '', { shouldDirty: true });
                      methods.setValue('presentation_global_source_key', '', { shouldDirty: true });
                    } else if (nextValue.startsWith('room:')) {
                      methods.setValue('presentation_source_friendly_id', nextValue.replace('room:', ''), { shouldDirty: true });
                      methods.setValue('presentation_global_source_key', '', { shouldDirty: true });
                    } else if (nextValue.startsWith('global:')) {
                      methods.setValue('presentation_global_source_key', nextValue.replace('global:', ''), { shouldDirty: true });
                      methods.setValue('presentation_source_friendly_id', '', { shouldDirty: true });
                    }

                    if (nextValue) {
                      methods.setValue('presentation', null, { shouldDirty: true });
                    }
                  }}
                >
                  <option value="">
                    {(libraryLoading || globalTemplatesLoading)
                      ? copy.loadingLibrary
                      : ((libraryFiles.length || availableGlobalTemplates.length) ? copy.selectLibrary : copy.noLibrary)}
                  </option>
                  {myFiles.length > 0 && (
                    <optgroup label={copy.myFiles}>
                      {myFiles.map((room) => (
                        <option key={`my-file-${room.friendly_id}`} value={`room:${room.friendly_id}`}>
                          {formatLibraryOptionLabel(room)}
                        </option>
                      ))}
                    </optgroup>
                  )}
                  {(sharedFiles.length > 0 || availableGlobalTemplates.length > 0) && (
                    <optgroup label={copy.sharedFiles}>
                      {sharedFiles.map((room) => (
                        <option key={`shared-file-${room.friendly_id}`} value={`room:${room.friendly_id}`}>
                          {formatLibraryOptionLabel(room)}
                        </option>
                      ))}
                      {availableGlobalTemplates.map((template) => (
                        <option key={`global-template-${template.key}`} value={`global:${template.key}`}>
                          {template.name}
                        </option>
                      ))}
                    </optgroup>
                  )}
                </select>
                <div className="ak-create-room-file-meta">
                  <span>{copy.selectedLibrary}</span>
                  <strong>
                    {selectedLibraryFile ? formatLibraryOptionLabel(selectedLibraryFile) : (
                      selectedGlobalTemplate ? selectedGlobalTemplate.name : copy.noLibrarySelected
                    )}
                  </strong>
                </div>
              </div>

              <div className="ak-create-room-section ak-create-room-section-spaced">
                <div className="ak-create-room-choice-grid">
                  <button
                    type="button"
                    className={`ak-create-room-choice ${selectedDestination === 'files' ? 'is-active' : ''}`}
                    onClick={() => methods.setValue('post_create_tab', 'files', { shouldDirty: true })}
                  >
                    {copy.filesNow}
                  </button>
                  <button
                    type="button"
                    className={`ak-create-room-choice ${selectedDestination === 'default' ? 'is-active' : ''}`}
                    onClick={() => methods.setValue('post_create_tab', 'default', { shouldDirty: true })}
                  >
                    {copy.filesLater}
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>

        <aside className="ak-create-room-preview">
          <span className="ak-create-room-preview-title">{copy.previewTitle}</span>
          <div className="ak-create-room-preview-card">
            <div className="ak-create-room-preview-icon" aria-hidden="true">
              {selectedThumbnail ? (
                <img
                  src={previewThumbnailUrl}
                  alt=""
                  className="ak-create-room-preview-image"
                />
              ) : selectedIcon.emoji}
            </div>
            <div>
              <strong>{methods.watch('name') || t('forms.room.fields.name.placeholder')}</strong>
              <p>{selectedThumbnail ? copy.thumbnailLabel : selectedIcon.label}</p>
            </div>
          </div>
          <p className="ak-create-room-preview-copy">{copy.previewBody}</p>
          <BootstrapForm.Text className="ak-create-room-preview-note">
            {selectedDestination === 'settings' && copy.settingsNow}
            {selectedDestination === 'files' && copy.filesNow}
            {selectedDestination === 'list' && copy.settingsLater}
            {selectedDestination === 'default' && copy.filesLater}
          </BootstrapForm.Text>
        </aside>
      </div>

      <Stack className="mt-3" direction="horizontal" gap={2}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          { t('close') }
        </Button>
        <Button variant="brand" type="submit" disabled={createRoomAPI.isLoading} className="ak-create-room-submit">
          {createRoomAPI.isLoading && <Spinner className="me-2" />}
          { t('room.create_room') }
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoomForm.propTypes = {
  handleClose: PropTypes.func,
  mutation: PropTypes.func.isRequired,
  userId: PropTypes.string.isRequired,
};

CreateRoomForm.defaultProps = {
  handleClose: () => { },
};

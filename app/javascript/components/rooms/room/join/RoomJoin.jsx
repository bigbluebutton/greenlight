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

/* eslint-disable consistent-return */
import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Navigate, Link, useLocation, useParams,
} from 'react-router-dom';
import {
  Button, Col, Row, Spinner, Stack, Form as RegularForm,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import usePublicRoom from '../../../../hooks/queries/rooms/usePublicRoom';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomStatus from '../../../../hooks/mutations/rooms/useRoomStatus';
import useEnv from '../../../../hooks/queries/env/useEnv';
import { joinFormConfig, joinFormFields as fields } from '../../../../helpers/forms/JoinFormHelpers';
import RequireAuthentication from './RequireAuthentication';
import GGSpinner from '../../../shared_components/utilities/GGSpinner';
import Logo from '../../../shared_components/Logo';
import Avatar from '../../../users/user/Avatar';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import FormControlGeneric from '../../../shared_components/forms/FormControlGeneric';
import RoomJoinPlaceholder from './RoomJoinPlaceholder';
import {
  useLocationCookie, useDefaultJoinName, useRoomChannelSubscription, useMeetingStarted, useFailedJoinAttempt, useHandleJoin,
} from './RoomJoinHooks';

export default function RoomJoin() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const [hasStarted, setHasStarted] = useState(false);

  const publicRoom = usePublicRoom(friendlyId);
  const roomStatusAPI = useRoomStatus(friendlyId);

  const { data: env } = useEnv();

  const methods = useForm(joinFormConfig);

  const location = useLocation();
  const path = encodeURIComponent(location.pathname);

  const reset = () => { setHasStarted(false); };// Reset pipeline;

  const handleJoin = useHandleJoin({
    publicRoom, methods, t, roomStatusAPI,
  });

  // Set/unset the location cookie if user uses the back functionality
  useLocationCookie(path);

  // Set the default join name if the user is authenticated
  useDefaultJoinName({ currentUser, methods });

  // Subscribe to the room channel
  useRoomChannelSubscription({ roomStatusAPI, friendlyId, setHasStarted });

  // Check if the meeting has started
  useMeetingStarted({
    hasStarted, friendlyId, t, methods, handleJoin, reset,
  });

  // Check if the user has failed to join the meeting
  useFailedJoinAttempt({
    roomStatusAPI, methods, t, publicRoom, reset,
  });

  if (publicRoom.isLoading) return <RoomJoinPlaceholder />;

  if (!currentUser.signed_in && publicRoom.data.require_authentication === 'true') {
    return <RequireAuthentication path={path} />;
  }

  if (publicRoom.data.owner_id === currentUser?.id || publicRoom.data.shared_user_ids.includes(currentUser?.id)) {
    return <Navigate to={`/rooms/${publicRoom.data.friendly_id}`} />;
  }

  const hasAccessCode = publicRoom.data?.viewer_access_code || publicRoom.data?.moderator_access_code;

  if (publicRoom.data?.viewer_access_code || !publicRoom.data?.moderator_access_code) {
    fields.accessCode.label = t('room.settings.access_code');
    // for the case where anyone_join_as_moderator is true and only the moderator access code is required
  } else if (publicRoom.data?.anyone_join_as_moderator === 'true') {
    fields.accessCode.label = t('room.settings.mod_access_code');
  } else {
    fields.accessCode.label = t('room.settings.mod_access_code_optional');
  }

  const WaitingPage = (
    <Stack direction="horizontal" className="py-4">
      <div>
        <h5>{t('room.meeting.meeting_not_started')}</h5>
        <span className="text-muted">{t('room.meeting.join_meeting_automatically')}</span>
      </div>
      <div className="d-block ms-auto">
        <GGSpinner />
      </div>
    </Stack>
  );

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 card-shadow">
        <Card.Body className="pt-4 px-5">
          <Row>
            <Col className="col-xxl-8">
              <span className="text-muted">{t('room.meeting.meeting_invitation')}</span>
              <h1 className="mt-2">
                {publicRoom?.data.name}
              </h1>
            </Col>
            <Col>
              <Stack direction="vertical" gap={3}>
                <Avatar className="d-block ms-auto me-auto" avatar={publicRoom?.data.owner_avatar} size="medium" />
                <h5 className="text-center">{publicRoom?.data.owner_name}</h5>
              </Stack>
            </Col>
          </Row>
        </Card.Body>
        <Card.Footer className="px-5 pb-3 bg-white border-2">
          {(roomStatusAPI.isSuccess && !roomStatusAPI.data.status) ? WaitingPage : (
            <Form methods={methods} onSubmit={handleJoin}>
              <FormControl field={fields.name} type="text" disabled={currentUser?.signed_in} autoFocus={!currentUser?.signed_in} />
              {hasAccessCode && <FormControl field={fields.accessCode} type="text" autoFocus={currentUser?.signed_in} />}
              {publicRoom?.data?.recording_consent === 'true' && (
                <FormControlGeneric
                  id={fields.recordingConsent.controlId}
                  className="text-muted"
                  field={fields.recordingConsent}
                  label={fields.recordingConsent.label}
                  control={RegularForm.Check}
                  type="checkbox"
                />
              )}

              <Button
                variant="brand"
                className="mt-3 d-block float-end"
                type="submit"
                disabled={publicRoom.isFetching || roomStatusAPI.isLoading}
              >
                {roomStatusAPI.isLoading && <Spinner className="me-2" />}
                {t('room.meeting.join_meeting')}
              </Button>
            </Form>
          )}
        </Card.Footer>
      </Card>
      {!currentUser?.signed_in && (
        env?.OPENID_CONNECT ? (
          <Stack direction="horizontal" className="d-flex justify-content-center text-muted mt-3"> {t('authentication.already_have_account')}
            <RegularForm action="/auth/openid_connect" method="POST" data-turbo="false">
              <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
              <Button variant="link" className="btn-sm fs-6 cursor-pointer ms-2 ps-0" type="submit">{t('authentication.sign_in')}</Button>
            </RegularForm>
          </Stack>
        ) : (
          <div className="text-center text-muted mt-3"> {t('authentication.already_have_account')}
            <Link to={`/signin?location=${path}`} className="text-link ms-1"> {t('authentication.sign_in')} </Link>
          </div>
        )
      )}
    </div>
  );
}

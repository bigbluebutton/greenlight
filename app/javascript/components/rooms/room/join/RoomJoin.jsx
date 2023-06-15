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
import React, { useState, useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Navigate, Link, useParams,
} from 'react-router-dom';
import {
  Button, Col, Row, Stack, Form as RegularForm,
} from 'react-bootstrap';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import usePublicRoom from '../../../../hooks/queries/rooms/usePublicRoom';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomStatus from '../../../../hooks/mutations/rooms/useRoomStatus';
import useEnv from '../../../../hooks/queries/env/useEnv';
import subscribeToRoom from '../../../../channels/rooms_channel';
import RequireAuthentication from './RequireAuthentication';
import GGSpinner from '../../../shared_components/utilities/GGSpinner';
import Spinner from '../../../shared_components/utilities/Spinner';
import Logo from '../../../shared_components/Logo';
import Avatar from '../../../users/user/Avatar';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';
import FormControlGeneric from '../../../shared_components/forms/FormControlGeneric';
import RoomJoinPlaceholder from './RoomJoinPlaceholder';
import useRoomJoinForm from '../../../../hooks/forms/rooms/useRoomJoinForm';
import {Helmet} from "react-helmet";

export default function RoomJoin() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const [hasStarted, setHasStarted] = useState(false);

  const publicRoom = usePublicRoom(friendlyId);
  const roomStatusAPI = useRoomStatus(friendlyId);

  const { data: env } = useEnv();

  const { methods, fields } = useRoomJoinForm();

  const path = encodeURIComponent(document.location.pathname);

  useEffect(() => { // set cookie to return to if needed
    const date = new Date();
    date.setTime(date.getTime() + (60 * 1000)); // expire the cookie in 1min
    document.cookie = `location=${path};path=/;expires=${date.toGMTString()}`;

    return () => { // delete redirect location when unmounting
      document.cookie = `location=${path};path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT`;
    };
  }, []);

  const handleJoin = (data) => {
    document.cookie = 'location=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT'; // delete redirect location

    if (publicRoom?.data.viewer_access_code && !methods.getValues('access_code')) {
      return methods.setError('access_code', { type: 'required', message: t('room.settings.access_code_required') }, { shouldFocus: true });
    }

    roomStatusAPI.mutate(data);
  };
  const reset = () => { setHasStarted(false); };// Reset pipeline;

  useEffect(() => {
    // Default Join name to authenticated user full name.
    if (currentUser?.name) {
      methods.setValue('name', currentUser.name);
    }
  }, [currentUser?.name]);

  useEffect(() => {
    // Room channel subscription:
    if (roomStatusAPI.isSuccess) {
      //  When the user provides valid input (name, codes) the UI will subscribe to the room channel.
      const channel = subscribeToRoom(friendlyId, { onReceived: () => { setHasStarted(true); } });

      //  Cleanup: On component unmounting any opened channel subscriptions will be closed.
      return () => {
        channel.unsubscribe();
        console.info(`WS: unsubscribed from room(friendly_id): ${friendlyId} channel.`);
      };
    }
  }, [roomStatusAPI.isSuccess]);

  // Play a sound and displays a toast when the meeting starts if the user was in a waiting queue
  const notifyMeetingStarted = () => {
    const audio = new Audio(`${process.env.RELATIVE_URL_ROOT}/audios/notify.mp3`);
    audio.play()
      .catch((err) => {
        console.error(err);
      });
    toast.success(t('toast.success.room.meeting_started'));
  };

  // Returns a random delay between 2 and 5 seconds, in increments of 250 ms
  // The delay is to let the BBB server settle before attempting to join the meeting
  // The randomness is to prevent multiple users from joining the meeting at the same time
  const joinDelay = () => {
    const min = 4000;
    const max = 7000;
    const step = 250;

    // Calculate the number of possible steps within the given range
    const numSteps = (max - min) / step;

    // Generate a random integer from 0 to numSteps (inclusive)
    const randomStep = Math.floor(Math.random() * (numSteps + 1));

    // Calculate and return the random delay
    return min + (randomStep * step);
  };

  useEffect(() => {
    // Meeting started:
    //  When meeting starts this logic will be fired, indicating the event to waiting users (through a toast) for UX matter.
    //  Logging the event for debugging purposes and refetching the join logic with the user's given input (name & codes).
    if (hasStarted) {
      console.info(`Attempting to join the room(friendly_id): ${friendlyId} meeting.`);
      const delay = joinDelay();
      setTimeout(notifyMeetingStarted, delay - 1000);
      setTimeout(methods.handleSubmit(handleJoin), delay); // TODO: Amir - Improve this race condition handling by the backend.
      reset();// Resetting the Join component.
    }
  }, [hasStarted]);

  useEffect(() => {
    // UI synchronization on failing join attempt:
    //  When the room status API returns an error indicating a failed join attempt it's highly due to stale credentials.
    //  In such case, users from a UX perspective will appreciate having the UI updated informing them about the case.
    //  i.e: Indicating the lack of providing access code value for cases where access code was generated while the user was waiting.
    if (roomStatusAPI.isError) {
      // Invalid Access Code SSE (Server Side Error):
      if (roomStatusAPI.error.response.status === 403) {
        methods.setError('access_code', { type: 'SSE', message: t('room.settings.wrong_access_code') }, { shouldFocus: true });
      }

      publicRoom.refetch();// Refetching room public information.
      reset();// Resetting the Join component.
    }
  }, [roomStatusAPI.isError]);

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
      <Helmet>
        <title>{publicRoom?.data.name}</title>
        <meta property="og:title" content={publicRoom?.data.name} />
      </Helmet>
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
            <RegularForm action={process.env.OMNIAUTH_PATH} method="POST" data-turbo="false">
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

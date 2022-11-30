import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Button, Col, Form as RegularForm, Row, Spinner, Stack,
} from 'react-bootstrap';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import Logo from '../shared_components/Logo';
import Form from '../shared_components/forms/Form';
import FormControl from '../shared_components/forms/FormControl';
import useInstantRoom from '../../hooks/queries/meetings/useInstantRoom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useJoinInstantMeeting from '../../hooks/mutations/meetings/useJoinInstantMeeting';
import { joinInstantMeetingFormConfig, joinInstantMeetingFormFields as fields } from '../../helpers/forms/JoinInstantMeetingFormHelpers';

export default function InstantRoomJoin() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const instantRoom = useInstantRoom(friendlyId);
  const joinInstantMeeting = useJoinInstantMeeting(friendlyId);
  const currentUser = useAuth();
  const methods = useForm(joinInstantMeetingFormConfig);

  const handleJoin = (data) => {
    document.cookie = 'location=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT'; // delete redirect location

    joinInstantMeeting.mutate(data);
  };

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
        <Card.Body className="pt-4 px-5">
          <span className="text-muted">{t('room.meeting.meeting_invitation')}</span>
          <h1 className="mt-2">
            {instantRoom?.data?.name}
          </h1>
        </Card.Body>
        <Card.Footer className="px-5 pb-3 bg-white border-2">
          <Form methods={methods} onSubmit={handleJoin}>
            <FormControl field={fields.name} type="text" disabled={currentUser?.signed_in} autoFocus={!currentUser?.signed_in} />
            <Button
              variant="brand"
              className="mt-3 d-block float-end"
              type="submit"
              disabled={instantRoom.isFetching || joinInstantMeeting.isLoading}
            >
              {joinInstantMeeting.isLoading && <Spinner className="me-2" />}
              {t('room.meeting.join_meeting')}
            </Button>
          </Form>
        </Card.Footer>
      </Card>
    </div>
  );
}

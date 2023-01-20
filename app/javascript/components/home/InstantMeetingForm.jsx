import React from 'react';
import { useForm } from 'react-hook-form';
import { Button } from 'react-bootstrap';
import Form from '../shared_components/forms/Form';
import FormControl from '../shared_components/forms/FormControl';
import { instantMeetingFormConfig, instantMeetingFormFields as fields } from '../../helpers/forms/InstantMeetingFormHelpers';
import useInstantMeeting from '../../hooks/mutations/meetings/useInstantMeeting';
import Spinner from '../shared_components/utilities/Spinner';

export default function InstantMeetingForm() {
  const methods = useForm(instantMeetingFormConfig);
  const instantMeeting = useInstantMeeting();

  return (
    <Form methods={methods} onSubmit={instantMeeting.mutate}>
      <FormControl field={fields.username} type="text" />

      <Button
        variant="brand"
        className="btn mt-3 d-block float-end"
        type="submit"
      >
        {instantMeeting?.isLoading
          ? <Spinner className="me-2" />
          : 'Démarrer la réunion'}
      </Button>
    </Form>
  );
}

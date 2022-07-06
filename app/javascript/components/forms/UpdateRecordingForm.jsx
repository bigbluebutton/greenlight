import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useForm } from 'react-hook-form';
import FormControl from './FormControl';
import Form from './Form';
import { UpdateRecordingsFormConfig, UpdateRecordingsFormFields } from '../../helpers/forms/UpdateRecordingsFormHelpers';
import useUpdateRecording from '../../hooks/mutations/recordings/useUpdateRecording';

export default function UpdateRecordingForm({
  name, noLabel, recordId, hidden, setIsUpdating,
}) {
  const updateRecording = useUpdateRecording(recordId);
  UpdateRecordingsFormConfig.defaultValues.name = name;
  const methods = useForm(UpdateRecordingsFormConfig);
  const fields = UpdateRecordingsFormFields;
  useEffect(() => { setIsUpdating(updateRecording.isLoading); }, [updateRecording.isLoading]);

  return (
    <Form
      methods={methods}
      onBlur={methods.handleSubmit(updateRecording.mutate)}
      hidden={hidden}
    >
      <FormControl field={fields.name} noLabel={noLabel} type="text" disabled={updateRecording.isLoading} />
    </Form>
  );
}

UpdateRecordingForm.defaultProps = {
  name: '',
  noLabel: true,
  hidden: false,
  setIsUpdating: () => { },
};

UpdateRecordingForm.propTypes = {
  name: PropTypes.string,
  noLabel: PropTypes.bool,
  recordId: PropTypes.string.isRequired,
  hidden: PropTypes.bool,
  setIsUpdating: PropTypes.func,
};

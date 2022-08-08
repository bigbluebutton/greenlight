import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { useForm } from 'react-hook-form';
import FormControl from '../../forms/FormControl';
import Form from '../../forms/Form';
import { UpdateRecordingsFormConfig, UpdateRecordingsFormFields } from '../../../helpers/forms/UpdateRecordingsFormHelpers';

export default function UpdateRecordingForm({
  name, noLabel, recordId, hidden, setIsUpdating, mutation: useUpdateAPI,
}) {
  const updateAPI = useUpdateAPI(recordId);

  UpdateRecordingsFormConfig.defaultValues.name = name;

  const methods = useForm(UpdateRecordingsFormConfig);
  const fields = UpdateRecordingsFormFields;

  useEffect(() => { setIsUpdating(updateAPI.isLoading); }, [updateAPI.isLoading]);

  return (
    <Form methods={methods} onBlur={methods.handleSubmit(updateAPI.mutate)} hidden={hidden}>
      <FormControl
        field={fields.name}
        noLabel={noLabel}
        type="text"
        disabled={updateAPI.isLoading}
      />
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
  mutation: PropTypes.func.isRequired,
};

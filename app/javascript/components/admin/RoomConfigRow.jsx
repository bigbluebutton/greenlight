import React from 'react';
import PropTypes from 'prop-types';
import {
  Row, Stack, Form as BootStrapForm,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import FormControlGeneric from '../forms/FormControlGeneric';
import Form from '../forms/Form';
import { RoomConfigFormConfig, RoomConfigFormFields } from '../../helpers/forms/RoomConfigFormHelpers';

export default function RoomConfigRow({
  value, title, subtitle, mutation: useUpdateRoomConfig,
}) {
  const fields = RoomConfigFormFields;
  const { defaultValues } = RoomConfigFormConfig;
  defaultValues.value = value;

  const updateRoomConfig = useUpdateRoomConfig();
  const methods = useForm(RoomConfigFormConfig);

  return (
    <Row>
      <Stack className="my-2" direction="horizontal">
        <Stack>
          <strong> {title} </strong>
          <span className="text-muted"> {subtitle} </span>
        </Stack>
        <Form methods={methods} onChange={methods.handleSubmit(updateRoomConfig.mutate)}>
          <FormControlGeneric control={BootStrapForm.Select} field={fields.value} disabled={updateRoomConfig.isLoading}>
            <option value="optional">Optional</option>
            <option value="false">Disabled</option>
            <option value="true">Enabled</option>
          </FormControlGeneric>
        </Form>
      </Stack>
    </Row>
  );
}

RoomConfigRow.propTypes = {
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

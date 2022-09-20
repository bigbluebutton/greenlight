import React from 'react';
import PropTypes from 'prop-types';
import {
  Row, Stack, Form as BootStrapForm, Col,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import FormControlGeneric from '../../shared_components/forms/FormControlGeneric';
import Form from '../../shared_components/forms/Form';
import { RoomConfigFormConfig, RoomConfigFormFields } from '../../../helpers/forms/RoomConfigFormHelpers';

export default function RoomConfigRow({
  value, title, subtitle, mutation: useUpdateRoomConfig,
}) {
  const { t } = useTranslation();
  const fields = RoomConfigFormFields;
  const { defaultValues } = RoomConfigFormConfig;
  defaultValues.value = value;

  const updateRoomConfig = useUpdateRoomConfig();
  const methods = useForm(RoomConfigFormConfig);

  return (
    <Row className="mb-4">
      <Col md="9">
        <Stack>
          <strong> {title} </strong>
          <span className="text-muted"> {subtitle} </span>
        </Stack>
      </Col>
      <Col md="3">
        <Form className="mb-0 float-end" methods={methods} onChange={methods.handleSubmit(updateRoomConfig.mutate)}>
          <FormControlGeneric control={BootStrapForm.Select} field={fields.value} disabled={updateRoomConfig.isLoading}>
            <option value="optional">{ t('admin.room_configuration.optional') }</option>
            <option value="false">{ t('admin.room_configuration.disabled') }</option>
            <option value="true">{ t('admin.room_configuration.enabled') }</option>
          </FormControlGeneric>
        </Form>
      </Col>
    </Row>
  );
}

RoomConfigRow.propTypes = {
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

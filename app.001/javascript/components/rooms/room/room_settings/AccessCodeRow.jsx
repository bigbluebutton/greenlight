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

import React from 'react';
import PropTypes from 'prop-types';
import { Button, Row, Stack } from 'react-bootstrap';
import { TrashIcon, Square2StackIcon, ArrowPathIcon } from '@heroicons/react/24/outline';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';

export default function AccessCodeRow({
  settingName, description, code, updateMutation: useUpdateAPI, config,
}) {
  const { t } = useTranslation();
  const updateAPI = useUpdateAPI();
  const handleGenerateCode = () => updateAPI.mutate({ settingName, settingValue: true });
  const handleDeleteCode = () => updateAPI.mutate({ settingName, settingValue: false });

  // TODO: Samuel - Extract this into a shared helper function.
  const copyAccessCode = (copiedCode) => {
    navigator.clipboard.writeText(copiedCode);
    toast.success(t('toast.success.room.access_code_copied'));
  };

  if (config === 'false') {
    return null;
  }

  const deleteButton = ['optional', 'default_enabled'].includes(config) ? (
    <Button
      variant="icon"
      onClick={handleDeleteCode}
    >
      <TrashIcon className="hi-s text-muted" />
    </Button>
  ) : null;

  return (
    <Row className="my-3">
      <h6 className="text-brand">{description}</h6>
      {
        code
          ? (
            <Stack direction="horizontal">
              <div className="access-code-input w-100">
                <input type="text" className="form-control" value={code} readOnly />
                <Button
                  variant="icon"
                  className="mt-1"
                  onClick={() => copyAccessCode(code)}
                >
                  <Square2StackIcon className="hi-s text-muted" />
                </Button>
              </div>
              <Button
                variant="icon"
                className="mx-3"
                onClick={handleGenerateCode}
              >
                <ArrowPathIcon className="hi-s text-muted" />
              </Button>
              {deleteButton}
            </Stack>
          )
          : (
            <div>
              <Button
                variant="brand-outline"
                onClick={handleGenerateCode}
              >
                { t('room.settings.generate') }
              </Button>
            </div>
          )
      }
    </Row>
  );
}
AccessCodeRow.defaultProps = {
  code: '',
  config: 'false',
};

AccessCodeRow.propTypes = {
  code: PropTypes.string,
  config: PropTypes.string,
  settingName: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  updateMutation: PropTypes.func.isRequired,
};

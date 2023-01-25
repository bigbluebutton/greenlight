import { Dropdown, Stack } from 'react-bootstrap';
import React from 'react';
import PropTypes from 'prop-types';
import { ChevronDownIcon } from '@heroicons/react/20/solid';

export default function SettingSelect({
  defaultValue, title, description, children,
}) {
  // Get the currently selected option and set the dropdown toggle to that value
  const defaultString = children?.filter((item) => item.props.value === defaultValue)[0];

  return (
    <Stack direction="horizontal" className="mb-3">
      <Stack>
        <strong> { title } </strong>
        <div className="text-muted">{ description }</div>
      </Stack>
      <div className="ms-5">
        <Dropdown className="setting-select">
          <Dropdown.Toggle>
            { defaultString?.props?.children }
            <ChevronDownIcon className="hi-s float-end" />
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {children}
          </Dropdown.Menu>
        </Dropdown>
      </div>
    </Stack>
  );
}

SettingSelect.defaultProps = {
  defaultValue: '',
};

SettingSelect.propTypes = {
  defaultValue: PropTypes.string,
  title: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
};

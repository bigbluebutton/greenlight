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

import React, {
  useCallback, useEffect, useMemo, useReducer,
} from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';
import { ChevronDownIcon } from '@heroicons/react/20/solid';
import SelectContext from '../contexts/SelectContext';
import { ACTIONS } from '../constants/SelectConstants';
import Option from './Option';

const reducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.SELECT:
      return { value: action.msg.value };
    default:
      return state;
  }
};

const createOptionsFromChildren = (children) => {
  const options = {};

  React.Children.forEach(children, (elem) => {
    if (!elem) { return; }

    if (!React.isValidElement(elem)) {
      throw new Error('Only react elements are allowed inside of <Select> component.');
    }

    if (elem.type !== Option) { return; }

    const { children: title, value } = elem.props;

    if (!title || typeof title !== 'string') {
      throw new Error('An <Option> component was caught with an invalid title. All nested <Option> components must have a string children title.');
    }

    if (value === undefined || value === null || value === '') {
      throw new Error('An <Option> component was caught with no value prop. All nested <Option> components must have a value prop.');
    }

    if (options[value]) {
      throw new Error('An <Option> component was caught with a duplicated value. All nested <Option> components must have a unique value.');
    }

    options[value] = title;
  });

  return options;
};

export default function Select({
  children, id, variant, isValid, value, onChange, onBlur,
}) {
  const [selected, dispatch] = useReducer(reducer, { value });
  const handleBlur = useCallback(() => { onBlur(selected.value); }, [onBlur]);

  const current = useMemo(() => ({ selected, dispatch }), [selected.value]);
  const options = useMemo(() => createOptionsFromChildren(children), [React.Children.count(children)]);
  selected.title = options[selected.value];

  useEffect(() => { onChange(selected.value); }, [onChange, selected.value]);
  useEffect(() => { dispatch({ type: ACTIONS.SELECT, msg: { value } }); }, [value]);
  useEffect(() => {
    if (!selected.title) {
      console.error(`Unable to find an <Option> with value: "${selected.value}", this may not be expected and may lead to a bug.`);
    }
  }, [selected.title]);

  return (
    <SelectContext.Provider value={current}>
      <Dropdown id={id} className={`select d-grid mt-1 border-0 p-0 ${!isValid ? 'is-invalid' : ''}`}>
        <Dropdown.Toggle
          id="edit-user-dropdown"
          onBlur={handleBlur}
          className="text-start text-black border-1 form-control"
          variant={isValid ? variant : 'delete'}
        >
          {selected.title}
          <ChevronDownIcon className="hi-s text-muted float-end" />
        </Dropdown.Toggle>

        <Dropdown.Menu className="container-fluid">
          {children}
        </Dropdown.Menu>
      </Dropdown>
    </SelectContext.Provider>
  );
}

Select.defaultProps = {
  variant: 'brand-outline',
  id: undefined,
  onChange: () => { },
  onBlur: () => { },
  isValid: true,
  value: undefined,
};

Select.propTypes = {
  id: PropTypes.string,
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  variant: PropTypes.string,
  onChange: PropTypes.func,
  onBlur: PropTypes.func,
  isValid: PropTypes.bool,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]),
};

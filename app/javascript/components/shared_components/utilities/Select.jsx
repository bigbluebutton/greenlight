import React, {
  useCallback, useEffect, useMemo, useReducer,
} from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';
import SelectContext from '../contexts/SelectContext';
import { ACTIONS } from '../constants/SelectConstants';
import Option from './Option';

const reducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.SELECT:
      return { title: action.msg.title, value: action.msg.value };
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
  children, id, variant, isValid, defaultOpt, onChange, onBlur,
}) {
  const [selected, dispatch] = useReducer(reducer, defaultOpt);

  const current = useMemo(() => ({ selected, dispatch }), [selected.title, selected.value]);
  const handleBlur = useCallback(() => { onBlur(selected.value); }, [onBlur]);

  useEffect(() => { onChange(selected.value); }, [onChange, selected.value]);

  return (
    <SelectContext.Provider value={current}>
      <Dropdown id={id} className="select d-grid mt-1 border-0 p-0">
        <Dropdown.Toggle
          onBlur={handleBlur}
          className="text-start text-black border-1 form-control"
          variant={isValid ? variant : 'delete'}
        >
          {selected.title}
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
};

Select.propTypes = {
  id: PropTypes.string,
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  variant: PropTypes.string,
  onChange: PropTypes.func,
  onBlur: PropTypes.func,
  isValid: PropTypes.bool,
  defaultOpt: PropTypes.shape({
    title: PropTypes.string.isRequired,
    value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]),
  }).isRequired,
};

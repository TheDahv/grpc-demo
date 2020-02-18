const { h, render, Fragment } = preact;
const { useEffect, useState } = preactHooks;

const STATES = [
  'NOT_STARTED',
  'LOADING',
  'DONE',
  'ERROR',
].reduce((memo, field) => Object.assign(memo, { [field]: field }), {});

function App () {
  const [ status, setStatus ] = useState(STATES.NOT_STARTED);
  const [ people, setPeople ] = useState([]);

  useEffect(async () => {
    debugger
    setStatus(STATES.LOADING);
    const response = await fetch('/api/people');
    const { people } = await response.json();
    setPeople(people);

    setStatus(STATES.DONE);

    return async () => {
    };
  }, []);

  const renderPeople = people => (
    h('div', null, [
      h('table', null, [
        h('thead', null, [
          h('tr', null, [
            h('th', null, 'ID'),
            h('th', null, 'Name'),
            h('th', null, 'Has gRPC Experience'),
          ]),
        ]),
        h('tbody', null,
          people.map(person => (
            h('tr', null, [
              h('td', null, person.id),
              h('td', null, person.name),
              h('td', null, person.hasGrpcExperience ? 'Yes' : 'No'),
            ])
          ))
        ),
      ]),
    ])
  );

  return h('div', { className: 'container' }, [
    h('div', { className: 'row' }, [
      h('div', { className: 'col s12' }, [
        h('h1', null, 'People'),
      ]),
    ]),
    status === STATES.LOADING ?
      h('div', { className: 'progress' }, h('div', { className: 'indeterminate blue' })) :
      h('div', { className: 'row' }, [
        h('div', { className: 'col s12' }, renderPeople(people))
      ])
  ]);
}

const container = document.getElementById('container');
render(h(App), container, container);

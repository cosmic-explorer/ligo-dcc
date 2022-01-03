describe('Clones documents in multiple ways', () => {

//  it('', () => {
//  })
  const faker = require('faker')
  const masterDocumentNumber = 'T'+(100000+faker.datatype.number({'nbDigits': 8, 'strict':true}));

  it('Creates a master doc to clone', () => {
      cy.visit({
              url: "/cgi-bin/private/DocDB/ProcessDocumentAdd",
              method: "POST",
              auth: {
                username: 'admin',
                password: 'admin',
              },
              body: {
                  oldnumber: masterDocumentNumber,
                  mode: "use",
                  public: "",
                  requester: "3",
                  title: "Master doc",
                  abstract: "This doc is meant to be cloned",
                  keywords: "cypress POST automation test document ",
                  doctype: "10",
                  security: "2",
                  modify: "2",
                  authormanual: "One, User\nIstrator, Admin",
                  topics: 59,
              }
      })
  })

  it('Clones document '+masterDocumentNumber, () => {
      cy.visit('/LIGO-'+masterDocumentNumber, {
            auth: {
              username: 'admin',
              password: 'admin',
            },
          })
      cy.get('input[type=submit]').contains('Clone Document').should('be.visible').click()
      cy.get('dl.error').should('not.exist')
      cy.contains('You were successful.')
      cy.get('button.pda2bl').contains('Go To New Document').should('be.visible').click()
  })

  it('Uses XMLClone to clone the master doc '+masterDocumentNumber, () => {
  })
  it('Uses XMLClone to create multiple clones of  master doc '+masterDocumentNumber, () => {
  })
  it('Uses XMLUpload ', () => {
  })
})
describe('Check DocumentAddForm page', () => {
  it('opens the Reserve Number page', () => {
    cy.visit('/cgi-bin/private/DocDB/ReserveHome', {
      auth: {
        username: 'admin',
        password: 'admin',
      },
    })
    cy.get('input[value="Reserve"]').click()
  }) //it()

 it('Checks active elements on DocumentAddForm page', () => {
   //FIXME: needs actual checks if it makes sense
 }) //it()


  var docid

  it('Reserves a document number for a temporary test document', () => {
    cy.get('input[name=title]').type('First Doc')
    cy.get('textarea[name=abstract]').type('this is my abstract, FIXME: add some tex expression to test that later')
    cy.get('input[name=keywords]').type('cypress dcc automation test temporary')
    cy.get('input[name=doctype][value=10]').click()

     // GRRRR.... name= vs id= ....
    // viewable by
    cy.get('select[name=security]').first().select('LIGO_Lab')
    // modifiable by
    cy.get('select[name=modify]').last().select('Authors')
    //<textarea name="authormanual" rows="10" cols="35" id="authormanual"></textarea>
    cy.get('#authormanual').type('Istrator, Admin').click()
    // topics : temp test doc value=59
    cy.get('select[name=topics]').first().select('Temporary Test Document')

    cy.get('input[type=submit][value="Request document ID"]').last().click()

    // there is probably a better way e.g. https://stackoverflow.com/questions/56497146/submit-a-post-form-in-cypress-and-navigate-to-the-resulting-page
    // public:"" IS needed, otherwise it leads to misleading error message of no group allowed to view document
    cy.get('b').contains('LIGO-').then( (elm) => {
        docid= elm.get(0).outerText
        cy.log(docid)
    })

  }) //it()

// FIXME: this check is disabled because the XML output gives a text/html content-type
  it.skip('Checks xml output', () => {
       cy.get('button.pda2bl').contains('Go To New Document')
         .should('be.visible')
         .click()
       cy.location().then((loc) => {
             cy.log(loc['href'])
             cy.request(loc['href']+'?outformat=XML', {
                auth: {
                  username: 'admin',
                  password: 'admin',
                },
             }) //cy.visit
       })  // then
   })// it()

}) // describe()
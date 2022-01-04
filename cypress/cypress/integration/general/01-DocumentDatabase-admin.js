describe('private pages are served', () => {
  it('opens the DocumentDatabase page', () => {
    cy.visit('/dcc', {
      auth: {
        username: 'admin',
        password: 'admin',
      },
    })
    // check navbar links lead somewhere authorized
  })

  it('has all the expected links and buttons', () => {
    cy.contains('Administer').click()
    cy.contains('Reserve Number').click()
    cy.contains('Search').click()
    cy.contains('Recent').click()
    cy.contains('Changes').click()
    cy.contains('Topics').click()
    cy.contains('Events').click()
    // not clicking these , they are known to be problematic in the docker setup
    cy.contains('Public')
    cy.contains('Login')
    cy.contains('Help')
    cy.contains('Home').click()
    // check menu box and footer
    cy.contains('Instructions')
    cy.contains('My Account')
    cy.contains('Preferences')
    cy.contains('Using the DCC')
    cy.contains('Bulk Modify')
    cy.contains('Other DCC')
    cy.contains('KAGRA')
    cy.contains('Virgo TDS')
    cy.contains('Logged in as: admin')
    cy.contains('In Group(s):')
    cy.contains('contact DCC Help')
    // check that buttons are present in the main page form
    cy.get('input[value=Author]')
    cy.get('input[value=Authors]')
    cy.get('input[value=Title]')
    cy.get('input[value=Topics]')
    cy.get('input[value=Identifier]')
    cy.get('input[value=Changes]')
    cy.get('input[value="Access groups"]')
    cy.get('input[value="Events by type"]')
    cy.get('input[value="Events by date"]')
    // extra space at the end of the These Words
    cy.get('input[value="These Words "]')
    cy.get('input[value="Advanced search"]')
    cy.get('input[value="Signature Report"]')
  })

  it('has the right css and sponsor footer', () => {
    // check theme is correct
    cy.get('body').should('have.css', 'background-color', 'rgb(221, 238, 255)')

    // check nsf footer and background
    cy.contains('The LIGO Laboratory is supported by the National Science Foundation and operated jointly by Caltech and MIT. Any opinions, findings and conclusions or recommendations expressed in this material do not necessarily reflect the views of the National Science Foundation.')
    cy.get('body').should('have.css', 'background-image', 'url("https://localhost/site-logos/dcc-private-logo.png"), url("https://localhost/site-logos/NSF_4-Color_bitmap_Logo.png")')
  })

  it('checks the author autocomplete works', () => {
    // check author completion works
    // <li class="ui-menu-item" role="menuitem"><a class="ui-corner-all" tabindex="-1">One, User</a></li>
    cy.get('input[id=autocompleter').clear().type('On').wait(1000)
    // should be a bit more specific to select the li  with ARIA role of menuitem
    cy.contains('One, User').click()
    cy.get('input[value=Author]').click()
  })
})

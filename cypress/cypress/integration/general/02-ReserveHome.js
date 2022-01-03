//https://localhost/cgi-bin/private/DocDB/ReserveHome
describe('Check ReserveHome page', () => {
    it('opens the Reserve Number page', () => {
        cy.visit('/cgi-bin/private/DocDB/ReserveHome', {
            auth: {
                username: 'admin',
                password: 'admin',
            },
        })
    }) //it()

    it('Checks active elements on Reserve Number page', () => {
        cy.get('a').contains('Advanced')
        cy.get('input[value="Basic Search"]')
        cy.get('input[value="Number Search"]')
        cy.get('input[value="Use"]')
        cy.get('input[value="Reserve"]')
    }) //it()

 //FIXME: run searches (implies some docs are available


}) // describe()
describe('Changes the metadata of the document', () => {
//  it('', () => {
//  })
})

describe('Checks the document signature features', () => {
    const faker = require('faker')
    const document = {
         Number: 'M'+(100000+faker.datatype.number({'nbDigits': 8, 'strict':true})),
         requester: 3,
         Title: faker.lorem.sentence(),
         Abstract: faker.lorem.paragraph(),
         doctype: 7,
         authors:  "Two, User\nIstrator, Admin",
    }

    it('sets up a parallel signature', () => {
        cy.api_createDocument(document)
        cy.visit('/LIGO-'+document.Number+'-x0', {
            auth: {
                username: 'admin',
                password: 'admin',
            },
        })
        Cypress.on('uncaught:exception', (err, runnable) => {
            // returning false here prevents Cypress from
            // failing the test
            return false
        })
        cy.get("input[type=submit]").contains("Change Metadata").click()
        // {esc} to remove name completion
        cy.get("#signofflist").type("User One{esc}{enter}User Three{esc}{enter}")
        cy.get("input[name=parallelsignoff]").check()
        cy.get("input[type=submit]").contains("Change Metadata").last().click()
        cy.get("button.pda2bl").contains("View Document").should('be.visible')
    })

    it('checks email notification', () => {
         cy.mhGetMailsBySubject('Ready for signature: LIGO-'+document.Number+'-x0: '+document.Title)
           .should('have.length', 1);
    })

    it('checks signature block in document card', () => {
        cy.get("button.pda2bl").contains("View Document").click()
        cy.get("li").contains("waiting for signature").should('be.visible')
        cy.get("li").contains("waiting for approval").should('be.visible')
    })

    it('checks signature report for user1', () => {
        cy.visit('/dcc', {
            auth: {
                username: 'user1@local',
                password: 'password',
            },
        })
         cy.get('input[value="Signature Report"]').should('be.visible').click()
        // <input type="submit" name=".submit" value="Signature Report">
    })

    it('checks signature options for user1', () => {
        cy.visit('/LIGO-'+document.Number, {
            auth: {
                username: 'user1@local',
                password: 'password',
            },
        })
        // FIXME: user3 does not have access to the doc...
        cy.get("input[type=button][value=Sign]").should('be.visible')
        cy.get("input[type=button][value=Deny]").should('be.visible')
        cy.get("input[type=button][value=Abstain]").should('be.visible').click()
        cy.get('input[type=button][value="Clear selection"]').should('be.visible').click()
        //second email sent when cleared selection
        cy.mhGetMailsBySubject('Ready for signature: LIGO-'+document.Number+'-x0: '+document.Title)
          .should('have.length', 2);
    })

})
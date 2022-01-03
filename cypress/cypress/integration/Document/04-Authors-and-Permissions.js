describe('Check View Group members have access, other are barred', () => {
//  it('', () => {
//  })
//   beforeEach(() => {
//        const document = {
//            Number: 'M'+(100000+faker.datatype.number({'nbDigits': 8, 'strict':true})),
//            requester: 3,
//            Title: faker.lorem.sentence(),
//            Abstract: faker.lorem.paragraph(),
//            doctype: 7,
//            authors:  "One, User\nIstrator, Admin",
//        }
////   })
    const faker = require('faker')

    it('checks authors have access', () => {
        const document = {
            Number: 'M'+(100000+faker.datatype.number({'nbDigits': 8, 'strict':true})),
            requester: 3,
            Title: faker.lorem.sentence(),
            Abstract: faker.lorem.paragraph(),
            doctype: 7,
            authors:  "Two, User\nIstrator, Admin",
        }
        cy.api_createDocument(document)

        cy.visit('/LIGO-'+document.Number+'-x0', {
            auth: {
                username: 'user1@local',
                password: 'password',
            },
        })
        // user1 should have access because lvk member
        cy.get('#DocTitle').contains(document.Title).should('be.visible')
        cy.get('dl.error').should('not.exist')
        cy.visit('/LIGO-'+document.Number+'-x0', {
            auth: {
                username: 'user2@local',
                password: 'password',
            },
        })
        // user2 should have access because it's an author
        cy.get('#DocTitle').contains(document.Title).should('be.visible')
        cy.get('dl.error').should('not.exist')

        cy.visit('/LIGO-'+document.Number+'-x0', {
            auth: {
                username: 'user4@local',
                password: 'password',
            },
        })
        //user4 should not have access
        cy.get('#DocTitle').should('not.exist')
        cy.get('dl.error').should('be.visible').contains('not authorized')
    })

})
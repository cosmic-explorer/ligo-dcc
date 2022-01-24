describe('Creates a document with a known number and uploads a file for a new version', () => {
    const faker = require('faker')
    const masterDocumentNumber = 'M'+(100000+faker.datatype.number({'nbDigits': 8, 'strict':true}));

    it('Creates a document '+masterDocumentNumber+'-x0', () => {
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
                    title: "Second doc",
                    abstract: "This doc was POSTed directly from cypress",
                    keywords: "cypress POST automation test document ",
                    doctype: "7",
                    security: "2",
                    modify: "2",
                    authormanual: "One, User\nIstrator, Admin",
                    topics: 59,
                }
        })
        cy.get('dl.error').should('not.exist')

    }) //it()

    it('Creates a new version of '+masterDocumentNumber+' by uploading a file', () => {
        cy.visit('/LIGO-'+masterDocumentNumber+'-x0', {
              auth: {
                username: 'user1@local',
                password: 'password',
              },
            })
        //cy.get('#UpdateButtons > form:nth-child(2) > div > input[type=submit]:nth-child(3)').click()
        cy.contains('Upload LIGO-'+masterDocumentNumber+'-v1').click()
        cy.get('input[name=filedesc1]').type('description of file 1')
        cy.get('#upload1')
          .as('fileInput')
          .attachFile('ligologo_t.png')
        cy.get('input[type="submit"]').last().click()
        cy.get('dl.error').should('not.exist')
        cy.contains('You were successful.')
    }) //it()

    Cypress.on('uncaught:exception', (err, runnable) => {
        // returning false here prevents Cypress from
        // failing the test
        return false
    })

    it('Replaces a file to this version', () => {
        cy.visit('/LIGO-'+masterDocumentNumber+'-v1', {
              auth: {
                username: 'admin',
                password: 'admin',
              },
            })
        cy.contains('Replace Files').should('be.visible').click()
        cy.get('#upload1')
          .as('fileInput')
          .attachFile('ligologo_t.jpg')

        //FIXME: needs to fix the cgi script to handle the serverstatus notification
        // (did not include the proper javascript to check the serverstatus or include mathjax)
        cy.get('input[type=submit]').contains('Add Files').click()
        cy.get('dl.error').should('not.exist')
        cy.contains('You were successful')
    })

    it('Adds a file to this version', () => {
        const randomWord =faker.random.word()
        cy.visit('/LIGO-'+masterDocumentNumber+'-v1', {
            auth: {
              username: 'admin',
              password: 'admin',
            },
        })
        cy.contains('Replace Files').should('be.visible').click()
        cy.get('#upload1')
        .as('fileInput')
        .attachFile('lorem.pdf')
        cy.get('input[name=filedesc1]').type(randomWord)
        cy.get('input[type=submit]').contains('Add Files').click()
        cy.get('dl.error').should('not.exist')
        cy.contains('You were successful')
    })


})
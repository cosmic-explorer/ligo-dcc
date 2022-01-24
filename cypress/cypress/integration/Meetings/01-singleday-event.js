describe("Checks creation of single day event", () => {
  it('Checks the calendar for a link to create an event', () => {
     cy.visit('/cgi-bin/private/DocDB/ShowCalendar', {
        qs: {
          day: 4,
          month: 7,
          year: 1776
        },
        auth: {
                username: 'admin',
                password: 'admin',
        },
     })
  })

  it('Creates an event for GW150914', () => {
     cy.get('a').contains('Add a New Event on this Day').should('be.visible')
     // https://localhost/cgi-bin/private/DocDB/SessionModify?mode=new&singlesession=1&sessionyear=2022&sessionmonth=1&sessionday=10
     cy.visit('/cgi-bin/private/DocDB/SessionModify', {
        qs: {
            mode: 'new',
            singlesession: 1,
            sessionday: 14,
            sessionmonth: 9,
            sessionyear: 2015
        },
        auth: {
            username: 'admin',
            password: 'admin',
        }
     })
     cy.get('select[name=eventgroups]').select('other')
     cy.get('input[name=shortdesc]').type('GW150914')
     cy.get('input[name=long]').type('First direct detection of gravitational waves')
     cy.get('input[name=location]').type('LLO and LHO')
     cy.get('input[name=url]').type('https://dcc.ligo.org/P150914/public')
     cy.get('textarea[name=sessiondescription]').type('we did it !!!')
     cy.get('select#moderators').select(['One, User', 'Three, User'])
     cy.get('select[name=topics]').select('Other data analysis')
     cy.get('input[type=submit]').contains('Create Event and Talks').first().click()
     // check the outcome of creating the event
     cy.get('dd').contains('Created new event: GW150914').should('be.visible')
     cy.get('a').contains('Display the Event').should('be.visible')
     cy.get('a').contains('instructions').should('be.visible')
  })

  it('Adds Talks to GW150914', () => {
      cy.get('input[name=talktitle]').as('TalkTitles').first().type('First Talk')
      cy.get('@TalkTitles').last().type('Last Talk')
      cy.get('@TalkTitles').eq(1).type('Second Talk')
      // cy.get('input[name=talktitle]').contains('First Talk')

      cy.get('input[type=submit]').contains('Modify Event and Talks').first().click()
      cy.get('dd').contains('Added item to agenda: First Talk').should('be.visible')

  })

})
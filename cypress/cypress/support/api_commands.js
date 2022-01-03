Cypress.Commands.add('api_createDocument', document => {
    // document={
    //    Number: "M345210",
    //    requester: 3,
    //    Title: "test doc",
    //    Abstract: "Abstract bla, bla",
    //    authors: "Author 1\nAuhtor 2\n"
    // }
    cy.visit({
          url: "/cgi-bin/private/DocDB/ProcessDocumentAdd",
          method: "POST",
          auth: {
            username: 'admin',
            password: 'admin',
          },
          body: {
              oldnumber: document.Number,
              mode: "use",
              public: "",
              requester:  document.requester,
              title: document.Title,
              abstract: document.Abstract,
              keywords: "cypress POST automation test document ",
              doctype: document.doctype,
              security: "2",
              modify: "2",
              authormanual: document.authors,
              topics: 59,
          }
    })
})

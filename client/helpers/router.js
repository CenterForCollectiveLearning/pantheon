// Almost all session changes happen here!
// I.e. session is used to record state

// function splashCheck() {
//     return if Session.get("authorized") ? page else 'splash' 
// }

// Router.configure({
//     before: splashCheck
// })

Router.map(function() {
    this.route('observatory',
        {path: '/',
        before: [
            function() {
                this.redirect('/' + 
                    defaults.vizType + '/' + 
                    defaults.vizMode + '/' +
                    defaults.country + '/' +
                    defaults.language + '/' +                    
                    defaults.from + '/' +
                    defaults.to + '/' +
                    defaults.langs);
            }
        ]}
    );

    this.route('observatory', {
        path: '/observatory',
        before: [
            function() {
                this.redirect('/' + 
                    defaults.vizType + '/' + 
                    defaults.vizMode + '/' +
                    defaults.country + '/' +
                    defaults.language + '/' +                    
                    defaults.from + '/' +
                    defaults.to + '/' +
                    defaults.langs);
            }
        ]}
    );

    this.route('observatory', {
        path: '/:vizType/:vizMode/:param1/:param2/:from/:to/:langs',
        data: function() { 
            var vizMode = this.params.vizMode;
            Session.set('page', this.template);
            Session.set('vizType', this.params.vizType); 
            Session.set('vizMode', this.params.vizMode); 
            Session.set(IOMapping[vizMode]["in"][0], this.params.param1);  
            Session.set(IOMapping[vizMode]["in"][1], this.params.param2);  
            Session.set('from', this.params.from); 
            Session.set('to', this.params.to);  
            Session.set('langs', this.params.langs);  

            // Reset defaults based on vizmode
            if (vizMode == 'country_exports')
                Session.set("category", defaults.category)
            else if (vizMode == 'domain_exports_to')
                Session.set("country", defaults.country)
            else if (vizMode == 'country_vs_country') {
                Session.set("country", defaults.country);
                Session.set("category", defaults.category);
                Session.set("categoryLevel", defaults.categoryLevel);
            }
            else if (vizMode == 'domain_vs_domain')
                Session.set("category", defaults.category);

            if(IOMapping[vizMode]["in"][0] === "category" || IOMapping[vizMode]["in"][0] === "categoryX" || IOMapping[vizMode]["in"][0] === "categoryY") {
                Session.set("categoryLevel", getCategoryLevel(this.params.param1));
            }   
            if(IOMapping[vizMode]["in"][1] === "category" || IOMapping[vizMode]["in"][1] === "categoryX" || IOMapping[vizMode]["in"][1] === "categoryY") {
                Session.set("categoryLevel", getCategoryLevel(this.params.param2));   
            }
                
        }}
    );

    this.route('vision', {
        data: function() {
            Session.set('page', this.template);
        }
    });

    this.route('rankings', {
            path: '/rankings',
            before: [
                function() {
                    this.redirect('/rankings/' +
                        defaults.entity + '/' +
                        defaults.country + '/' +
                        defaults.category + '/' +
                        defaults.from + '/' +
                        defaults.to);
                }
            ]}
    );

    this.route('rankings', {
            path: '/rankings/:entity/:country/:category/:from/:to',
            data: function() {
                Session.set('page', this.template);
                Session.set('entity', this.params.entity);
                Session.set('country', this.params.country);
                Session.set('category', this.params.category);
                Session.set('from', this.params.from);
                Session.set('to', this.params.to);
            }}
    );

    this.route('data', {
        data: function() {
            Session.set('page', this.template);
        }
    });
    this.route('faq', {
        data: function() {
            Session.set('page', this.template);
        }
    });
    this.route('people', {
        data: function() { 
            Session.set('page', this.template);
        }
    });
    this.route('people', {
        path: '/people/:person',
        data: function() { 
            Session.set('page', this.template);
            Session.set('person', this.params.person);
        }
    });
    this.route('team', {
        data: function() {
            Session.set('page', this.template);
        }
    });
    this.route('publications', {
        data: function() {
            Session.set('page', this.template);
        }
    });
});

Router.configure({
    layout: 'defaultLayout',
    renderTemplates: {
        'nav': { to: 'nav'}
        , 'footer': { to: 'footer' }
    }
});

// Almost all session changes happen here!
// I.e. session is used to record state

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
        }}
    );

    this.route('vision', {
        data: function() {
            Session.set('page', this.template);
        }
    });
    this.route('ranking', {
        data: function() {
            Session.set('page', this.template);
        }
    });
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
    this.route('about', {
        data: function() {
            Session.set('page', this.template);
        }
    });

});

Router.configure({
  layout: 'defaultLayout',
  renderTemplates:
    {   'nav':
            { to: 'nav'},
        'footer':
            { to: 'footer' }
    },
  loadingTemplate: 'spinner'
});

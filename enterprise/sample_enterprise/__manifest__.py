{
    'name': 'Sample Enterprise Module',
    'version': '17.0.1.0.0',
    'category': 'Enterprise',
    'summary': 'Sample Enterprise Module for Testing',
    'description': '''
        This is a sample enterprise module to test your Odoo Enterprise setup.
        It demonstrates that enterprise addons are properly loaded.
    ''',
    'author': 'AdmasAfroLink',
    'website': 'https://admasafrolink.com',
    'license': 'LGPL-3',
    'depends': ['base'],
    'data': [
        'views/sample_views.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': False,
    'enterprise': True,
}

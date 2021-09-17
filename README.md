# agree-user-statements
Relates to GDPR compliance - stores versioned user accepted statements

NOTE: THIS IS A SET OF FILES AS AN EXAMPLE - IT'S NOT MEANT TO BE INSTALLABLE AS-IS
It is based on code in-use on the White Rose eTheses Online repository.

More details/documentation will be provided, but in the meantime, please ask questions - j.salter@leeds.ac.uk

There are user-agreements for:-
- user registration (storing user details)
- record creation (user agrees to us storing the bibliographic details/files they provide)
- request-a-copy (requestor agrees to us storing their details)

The code assumes that jQuery is in use on the repository.

There are additions to the user and request datasets.

Additions to user registration workflow:
```
<component type="Field::AgreeToStatement" surround="None">
  <field ref="privacy_statement" options="{$config{current_privacy_statement}}" required="yes" />
</component>
<component type="XHTML" surround="None">
  <epc:phrase ref="deposit_stylesheet"/>
  <epc:phrase ref="cgi/register:scripts"/>
</component>
```

Additions to request workflow:
```
<component type="Field::AgreeToStatement" surround="None">
  <field ref="privacy_statement" options="{$config{current_request_statement}}" required="yes" />
</component>
```

The 'disable submit button until statement has been (allegedly) read' is implemented by `cfg/static/javascript/jquery.agree_to_statement.js`.

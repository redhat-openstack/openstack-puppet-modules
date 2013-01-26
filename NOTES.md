As we're using the rspec fixtures structure, we can run them quite simply

    puppet apply --modulepath spec/fixtures/modules -e 'include demo1'

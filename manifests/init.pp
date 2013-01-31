define datacat($template) {
  file { $title:
    content  => "CHANGEME\n",
  }

  datacat_collector { $title:
    template      => $template,
    template_body => template_body($template),
    before        => File[$title], # when we evaluate we modify the private data of File
  }
}

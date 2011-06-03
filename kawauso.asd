(defsystem kawauso
    :version "0.0.0"
    :license "New BSD"
    :depends-on (clap-argparse clap-sys)
    :components
    ((:module "src" :components
              ((:file "kawauso")
               (:file "main" :depends-on ("kawauso"))
               ))))

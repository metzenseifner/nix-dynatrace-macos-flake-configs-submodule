return {
  -- names
  -- exec
  -- main
  -- program
  s("program-minimal", fmt([[
    package main 
    func main() {}
  ]],{},{delimiters="[]"})),
  
  s("why-go-mod", fmt([[
   1. Dependency Management: It lists all the dependencies your project needs,
   including their versions. This ensures that everyone working on the project
   uses the same versions of libraries.
   2. Versioning: It helps in maintaining consistent versions of dependencies
   across different environments, preventing issues that might arise from using
   different versions.
   3. Module Path: It defines the module path, which is the import path prefix
   for your project. This is useful for organizing and referencing your code.
   4. Reproducibility: It allows for reproducible builds. By specifying exact
   versions of dependencies, you can be sure that your project will build and
   run the same way every time. 

   Example go.mod
   
   module my-go-project
   
   go 1.18
   
   require (
       github.com/some/dependency v1.2.3
   )
  ]], {}, {delimiters="<>"})),
  s("init-a-project-in-existing-directory", fmt([[
     # Add module file go.mod
     go mod init minimal-go-project
     # Filename must be in format <name>.go
     touch main.go
     cat <<'EOF'
       # package name must not match file's name
       package main
       func main() {}
     EOF
  ]], {}, {delimiters="[]"}))
}

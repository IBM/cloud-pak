->Containerized Software Security Compliance<-

[[_toc]]

#What is the report? 

The Containerized Software Security Compliance Report is a PDF file that explains the security posture of a IBM Containerized product. The report states if the given IBM product is compliant or not for several security principles for containerized software. The security principles included are IBM standards, guidelines, and best practices for delivering secure, enterprise grade Kubernetes software. 

#Why does IBM provide the report? 

The report is intended to provide IBM customers with a simple way to understand the security compliance details necessary in containerized software. IBM understands how important security transparency is critical in enterprise ready software. IBM is taking strides to make the security posture of its products transparent, known, and easily understandable by anyone. The security data reported is necessary for anyone who is running containerized software. IBM is providing this so that it is easy to discover and be upfront about the security posture of IBM Software products. 

#Who should understand the report? 

Any IT or Security Administrator should be familiar with the security principles in this report when managing a Kubernetes cluster, thus allowing developers to deploy containers. This report provides a summary of key security principles in a single user friendly readable document.   

#How does IBM know the compliance? 

All IBM containerized software goes through a process called IBM Kubernetes Certification before publishing. An overview of the process is described in this IBM Developer blog post. IBM gathers over 100 pieces of data through this certification process to hold products accountable for complying with a rigorous set of standards and best practices. This report takes a few critical security principles from certification process and externalizes it 

#Where is the report? 

The report is shipped as part of the product's Container Application Software for Enterprises (CASE). The CASE is the well defined file structure that provides packaging and metadata about the software as well as the certification and provenance 

To view the security report, follow the sample steps below. 

Using your favorite Web browser view the IBM Cloud-pak Github Case repo 

Navigate to the desired product and version (ibm-example/v1.0) 

Download the tgz file 

Extract the tgz file 

$ tar –xzvf <path to download>/ibm-example-1.0.tgz 

Cd to certificates/security folder 

$ cd ibm-example/certifications/files 

View the report with your favorite PDF viewer 

 